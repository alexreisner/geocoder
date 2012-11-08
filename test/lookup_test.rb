# encoding: utf-8
require 'test_helper'

class LookupTest < Test::Unit::TestCase

  def test_search_returns_empty_array_when_no_results
    Geocoder::Lookup.all_services_except_test.each do |l|
      lookup = Geocoder::Lookup.get(l)
      set_api_key!(l)
      assert_equal [], lookup.send(:results, Geocoder::Query.new("no results")),
        "Lookup #{l} does not return empty array when no results."
    end
  end

  def test_does_not_choke_on_nil_address
    Geocoder::Lookup.all_services.each do |l|
      Geocoder::Configuration.lookup = l
      assert_nothing_raised { Venue.new("Venue", nil).geocode }
    end
  end

  def test_hash_to_query
    g = Geocoder::Lookup::Google.new
    assert_equal "a=1&b=2", g.send(:hash_to_query, {:a => 1, :b => 2})
  end

  def test_google_api_key
    Geocoder::Configuration.api_key = "MY_KEY"
    g = Geocoder::Lookup::Google.new
    assert_match "key=MY_KEY", g.send(:query_url, Geocoder::Query.new("Madison Square Garden, New York, NY  10001, United States"))
  end

  def test_geocoder_ca_showpostal
    Geocoder::Configuration.api_key = "MY_KEY"
    g = Geocoder::Lookup::GeocoderCa.new
    assert_match "showpostal=1", g.send(:query_url, Geocoder::Query.new("Madison Square Garden, New York, NY  10001, United States"))
  end

end
