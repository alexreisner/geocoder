require 'geocoder/cache_stores/base'

module Geocoder::CacheStore
  class Generic < Base
    def write(url, value)
      case
      when store.respond_to?(:[]=)
        store[key_for(url)] = value
      when store.respond_to?(:set)
        store.set key_for(url), value
      when store.respond_to?(:write)
        if (expiration = config[:expiration])
          store.write key_for(url), value, expires_in: expiration
        else
          store.write key_for(url), value
        end
      end
    end

    def read(url)
      case
      when store.respond_to?(:[])
        store[key_for(url)]
      when store.respond_to?(:get)
        store.get key_for(url)
      when store.respond_to?(:read)
        store.read key_for(url)
      end
    end

    def keys
      store.keys
    end

    def remove(key)
      store.delete(key)
    end
  end
end
