# encoding: utf-8
require 'test_helper'

class CacheTest < GeocoderTestCase

  ##
  # Simulate a Redis-like store whose class name is not recognized by the
  # cache store lookup (e.g. a Redis client wrapped in a custom class).
  #
  class RedisLikeStore
    attr_reader :last_set_options

    def initialize
      @data = {}
    end

    def set(key, value, options = {})
      @data[key] = value
      @last_set_options = options
    end

    def get(key)
      @data[key]
    end

    def del(key)
      @data.delete(key)
    end
  end

  def setup
    @tempfile = Tempfile.new("log")
    @logger = Logger.new(@tempfile.path)
    Geocoder.configure(logger: @logger)
  end

  def teardown
    Geocoder.configure(logger: :kernel)
    @logger.close
    @tempfile.close
  end

  def test_second_occurrence_of_request_is_cache_hit
    Geocoder.configure(:use_https => false)
    Geocoder.configure(:cache => {})
    Geocoder::Lookup.all_services_except_test.each do |l|
      next if
        # local, does not use cache
        l == :maxmind_local ||
        l == :geoip2 ||
        l == :ip2location_lite
      Geocoder.configure(:lookup => l)
      set_api_key!(l)
      results = Geocoder.search("Madison Square Garden")
      assert !results.first.cache_hit,
        "Lookup #{l} returned erroneously cached result."
      results = Geocoder.search("Madison Square Garden")
      assert results.first.cache_hit,
        "Lookup #{l} did not return cached result."
    end
  end

  def test_google_over_query_limit_does_not_hit_cache
    Geocoder.configure(:cache => {})
    Geocoder.configure(:lookup => :google)
    set_api_key!(:google)
    Geocoder.configure(:always_raise => :all)
    assert_raises Geocoder::OverQueryLimitError do
      Geocoder.search("over limit")
    end
    lookup = Geocoder::Lookup.get(:google)
    assert_equal false, lookup.instance_variable_get(:@cache_hit)
    assert_raises Geocoder::OverQueryLimitError do
      Geocoder.search("over limit")
    end
    assert_equal false, lookup.instance_variable_get(:@cache_hit)
  end

  def test_bing_service_unavailable_without_raising_does_not_hit_cache
    Geocoder.configure(cache: {}, lookup: :bing, always_raise: [])
    set_api_key!(:bing)
    lookup = Geocoder::Lookup.get(:bing)

    Geocoder.search("service unavailable")
    assert_false lookup.instance_variable_get(:@cache_hit)

    Geocoder.search("service unavailable")
    assert_false lookup.instance_variable_get(:@cache_hit)
  end

  def test_expire_all_urls
    Geocoder.configure(cache: {}, cache_options: {prefix: "geocoder:"})
    lookup = Geocoder::Lookup.get(:nominatim)
    lookup.cache['http://api.nominatim.com/'] = 'data'
    assert_operator 0, :<, lookup.cache.send(:keys).size
    lookup.cache.expire(:all)
    assert_equal 0, lookup.cache.send(:keys).size
  end

  def test_cache_store_instance_is_used_directly
    store_service = Geocoder::CacheStore::Generic.new({}, {})
    cache = Geocoder::Cache.new(store_service, {})
    assert_same store_service, cache.send(:store_service)
  end

  def test_cache_store_instance_applies_expiration
    redis_like_store = RedisLikeStore.new
    store_service = Geocoder::CacheStore::Redis.new(redis_like_store, {expiration: 120})
    cache = Geocoder::Cache.new(store_service, {})
    cache["http://example.com/"] = "data"
    assert_equal "data", cache["http://example.com/"]
    assert_equal({ex: 120}, redis_like_store.last_set_options)
  end

  def test_cache_store_instance_expire_single_url
    store_service = Geocoder::CacheStore::Redis.new(RedisLikeStore.new, {})
    cache = Geocoder::Cache.new(store_service, {})
    cache["http://example.com/"] = "data"
    cache.expire("http://example.com/")
    assert_nil cache["http://example.com/"]
  end

  def test_generic_cache_store_instance_expire_single_url
    store_service = Geocoder::CacheStore::Generic.new({}, {})
    cache = Geocoder::Cache.new(store_service, {})
    cache["http://example.com/"] = "data"
    cache.expire("http://example.com/")
    assert_nil cache["http://example.com/"]
  end
end
