# encoding: utf-8
require 'test_helper'

class LookupTest < Test::Unit::TestCase

  def test_search_returns_empty_array_when_no_results
    street_lookups.each do |l|
      Geocoder::Configuration.lookup = l
      assert_equal [], Geocoder.search("no results"),
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
