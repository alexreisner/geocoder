module Geocoder::CacheStore
  class Redis < Base
    def initialize(store, options)
      super
      @cache_expiration = options[:cache_expiration]
    end

    def write(url, value, expire = @cache_expiration)
      if expire.present?
        store.set key_for(url), value, ex: expire
      else
        store.set key_for(url), value
      end
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

    def expire; @cache_expiration; end
  end
end