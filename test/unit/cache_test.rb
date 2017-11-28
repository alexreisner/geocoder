# encoding: utf-8
require 'test_helper'

class CacheTest < GeocoderTestCase
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
    Geocoder.configure(:cache => {})
    Geocoder::Lookup.all_services_except_test.each do |l|
      next if l == :maxmind_local || l == :geoip2 # local, does not use cache
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

  def test_compress_cache_values_larger_than_1_kilobyte
    store = {}
    cache = Geocoder::Cache.new(store, "", compress: true)
    value = "a" * 1024

    cache["key"] = value

    assert_equal store["key"], "geocoder/compressed;#{Zlib::Deflate.deflate(value)}"
    assert_equal cache["key"], value
  end

  def test_dont_compress_cache_values_smaller_than_1_kilobyte
    store = {}
    cache = Geocoder::Cache.new(store, "", compress: true)
    value = "a" * 1023

    cache["key"] = value

    assert_equal store["key"], value
    assert_equal cache["key"], value
  end

  def test_read_compressed_cache_values_after_disabling_compression
    store = {}
    old_cache = Geocoder::Cache.new(store, "", compress: true)
    value = "a" * 1024
    old_cache["key"] = value

    new_cache = Geocoder::Cache.new(store, "", compress: false)

    # The old store value is compressed...
    assert_equal store["key"], "geocoder/compressed;#{Zlib::Deflate.deflate(value)}"

    # ...but the value can still be read properly
    assert_equal new_cache["key"], value
  end

  def test_explictly_disabling_compression_doesnt_compress
    store = {}
    cache = Geocoder::Cache.new(store, "", compress: false)
    value = "a" * 1024

    cache["key"] = value

    assert_equal store["key"], value
  end

  def test_read_uncompressed_cache_values_after_enabling_compression
    store = {}
    old_cache = Geocoder::Cache.new(store, "", compress: false)
    value = "a" * 1024
    old_cache["key"] = value

    new_cache = Geocoder::Cache.new(store, "", compress: true)

    # The old store value is not compressed...
    assert_equal store["key"], value

    # ...but the value can still be read properly
    assert_equal new_cache["key"], value
  end

  def test_nil_values_arent_compressed
    store = {}
    cache = Geocoder::Cache.new(store, "", compress: true)

    cache["key"] = nil

    assert_equal store["key"], nil
    assert_equal cache["key"], nil
  end
end
