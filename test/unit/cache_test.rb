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
end
