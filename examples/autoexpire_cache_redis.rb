# This class implements a cache with simple delegation to the Redis store, but
# when it creates a key/value pair, it also sends an EXPIRE command with a TTL.
# It should be fairly simple to do the same thing with Memcached.
class AutoexpireCacheRedis
  def initialize(store, ttl = 86400)
    @store = store
    @ttl = ttl
  end

  def [](url)
    @store.get(url)
  end

  def []=(url, value)
    @store.set(url, value)
    @store.expire(url, @ttl)
  end

  def keys
    @store.keys
  end

  def del(url)
    @store.del(url)
  end
end

Geocoder.configure(:cache => AutoexpireCacheRedis.new(Redis.new))
