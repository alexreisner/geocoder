require 'dalli/client'
require 'yaml'

class DalliClient
  # Setup Dalli as on Heroku using the Memcachier gem.
  # On other setups you'll have to specify your Memcached server
  def initialize(ttl = 86400)
    @keys = 'GeocoderDalliClientKeys'
    @store = Dalli::Client.new(:expires_in => ttl)
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
      key_cache_add(url) if @store.add(key, YAML::dump(value))
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
