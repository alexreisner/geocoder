module Geocoder::CacheStore
  class Redis < Base
    def initialize(store, options)
      super
      @expire = options[:expire]
    end

    def write(url, value)
      store.set key_for(url), value
    end

    def read(url)
      store.get key_for(url)
    end

    def keys
      store.keys("#{prefix}*")
    end

    def remove(key)
      store.del(key)
    end

    private # ----------------------------------------------------------------

    def expire; @expire; end
  end
end