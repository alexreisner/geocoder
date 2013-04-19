# This class implements a common cache interface with simple delegation to the chosen cache store.

require 'dalli_client'
require 'redis_client'

class AutoexpireCache
  def initialize(store_type = :redis, ttl = 86400)
    @store = case store_type
               when :redis
                 RedisClient.new(ttl)
               when :dalli
                 DalliClient.new(ttl)
               else
                 raise 'Unknown client type'
             end
  end

  def [](url)
    @store.[](url)
  end

  def []=(url, value)
    @store.[]=(url, value)
  end

  def keys
    @store.keys
  end

  def del(url)
    @store.del(url)
  end
end

Geocoder.configure(:cache => AutoexpireCache.new)
