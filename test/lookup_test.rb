# encoding: utf-8
require 'test_helper'

class LookupTest < Test::Unit::TestCase

  def test_search_returns_empty_array_when_no_results
    all_lookups.each do |l|
      lookup = Geocoder.send(:get_lookup, l)
      assert_equal [], lookup.send(:results, "no results"),
        "Lookup #{l} does not return empty array when no results."
    end
  end

  def test_hash_to_query
    g = Geocoder::Lookup::Google.new
    assert_equal "a=1&b=2", g.send(:hash_to_query, {:a => 1, :b => 2})
  end

  def test_google_api_key
    Geocoder::Configuration.api_key = "MY_KEY"
    g = Geocoder::Lookup::Google.new
    assert_match "key=MY_KEY", g.send(:query_url, "Madison Square Garden, New York, NY  10001, United States")
  end

  def test_yahoo_app_id
    Geocoder::Configuration.api_key = "MY_KEY"
    g = Geocoder::Lookup::Yahoo.new
    assert_match "appid=MY_KEY", g.send(:query_url, "Madison Square Garden, New York, NY  10001, United States")
  end
end
