require 'geocoder/cache_stores/base'

module Geocoder::CacheStore::ActiveSupport::Cache
  class RedisCacheStore < Geocoder::CacheStore::Base
    def write(url, value, expires_in = @config[:expiration])
      if expires_in.present?
        store.write(key_for(url), value, expires_in: expires_in)
      else
        store.write(key_for(url), value)
      end
    end

    def read(url)
      store.read(key_for(url))
    end

    def keys
      if store.redis.respond_to?(:with)
        store.redis.with do |redis|
          redis.scan_each(match: "#{prefix}*").to_a.uniq
        end
      else
        store.redis.scan_each(match: "#{prefix}*").to_a.uniq
      end
    end

    def urls
      return keys if prefix.blank?

      keys.map { |key| key.delete_prefix(prefix) }
    end

    def expire_single_url(url)
      store.delete(key_for(url))
    end
  end
end
