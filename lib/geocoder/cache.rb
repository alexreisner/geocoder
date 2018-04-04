require "zlib"

module Geocoder
  class Cache

    COMPRESS_THRESHOLD = 1024 # bytes
    COMPRESS_MARKER = "geocoder/compressed;"

    def initialize(store, prefix, options = {})
      @store = store
      @prefix = prefix
      @compress = options.fetch(:compress, false)
    end

    ##
    # Read from the Cache.
    #
    def [](url)
      value = interpret case
        when store.respond_to?(:[])
          store[key_for(url)]
        when store.respond_to?(:get)
          store.get key_for(url)
        when store.respond_to?(:read)
          store.read key_for(url)
      end

      if compressed?(value)
        uncompress(value)
      else
        value
      end
    end

    ##
    # Write to the Cache.
    #
    def []=(url, value)
      if should_compress?(value)
        value = compress(value)
      end

      case
        when store.respond_to?(:[]=)
          store[key_for(url)] = value
        when store.respond_to?(:set)
          store.set key_for(url), value
        when store.respond_to?(:write)
          store.write key_for(url), value
      end
    end

    ##
    # Delete cache entry for given URL,
    # or pass <tt>:all</tt> to clear all URLs.
    #
    def expire(url)
      if url == :all
        if store.respond_to?(:keys)
          urls.each{ |u| expire(u) }
        else
          raise(NoMethodError, "The Geocoder cache store must implement `#keys` for `expire(:all)` to work")
        end
      else
        expire_single_url(url)
      end
    end


    private # ----------------------------------------------------------------

    def prefix; @prefix; end
    def store; @store; end

    ##
    # Cache key for a given URL.
    #
    def key_for(url)
      [prefix, url].join
    end

    ##
    # Array of keys with the currently configured prefix
    # that have non-nil values.
    #
    def keys
      store.keys.select{ |k| k.match(/^#{prefix}/) and interpret(store[k]) }
    end

    ##
    # Array of cached URLs.
    #
    def urls
      keys.map{ |k| k[/^#{prefix}(.*)/, 1] }
    end

    ##
    # Clean up value before returning. Namely, convert empty string to nil.
    # (Some key/value stores return empty string instead of nil.)
    #
    def interpret(value)
      value == "" ? nil : value
    end

    def expire_single_url(url)
      key = key_for(url)
      store.respond_to?(:del) ? store.del(key) : store.delete(key)
    end

    def compression_enabled?
      @compress == true
    end

    def should_compress?(value)
      compression_enabled? && value && value.bytesize >= COMPRESS_THRESHOLD
    end

    def compressed?(value)
      value && value.start_with?(COMPRESS_MARKER)
    end

    def compress(value)
      COMPRESS_MARKER + Zlib::Deflate.deflate(value)
    end

    def uncompress(value)
      value = value[COMPRESS_MARKER.size..-1]
      Zlib::Inflate.inflate(value)
    end
  end
end
