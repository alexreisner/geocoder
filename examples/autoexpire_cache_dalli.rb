# This class implements a cache with simple delegation to the the Dalli Memcached client
# https://github.com/mperham/dalli
#
# A TTL is set on initialization

class AutoexpireCacheDalli
  def initialize(store, ttl = 86400)
    @store = store
    @keys = 'GeocoderDalliClientKeys'
    @ttl = ttl
  end

  def [](url)
    res = @store.get(url)
    res = YAML::load(res) if res.present?
    res
  end

  def []=(url, value)
    if value.nil?
      del(url)
    else
      key_cache_add(url) if @store.add(key, YAML::dump(value), @ttl)
    end
    value
  end

  def keys
    key_cache
  end

  def del(url)
    key_cache_delete(url) if @store.delete(key)
  end

  private

  def key_cache
    the_keys = @store.get(@keys)
    if the_keys.nil?
      @store.add(@keys, YAML::dump([]))
      []
    else
      YAML::load(the_keys)
    end
  end

  def key_cache_add(key)
    @store.replace(@keys, YAML::dump(key_cache << key))
  end

  def key_cache_delete(key)
    tmp = key_cache
    tmp.delete(key)
    @store.replace(@keys, YAML::dump(tmp))
  end
end

# Here Dalli is set up as on Heroku using the Memcachier gem.
# https://devcenter.heroku.com/articles/memcachier#ruby
# On other setups you might have to specify your Memcached server in Dalli::Client.new
Geocoder.configure(:cache => AutoexpireCacheDalli.new(Dalli::Client.new))
