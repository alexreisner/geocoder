# encoding: utf-8
require 'test_helper'

class MapboxTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(lookup: :mapbox)
    set_api_key!(:mapbox)
  end

  def test_url_contains_api_key
    Geocoder.configure(mapbox: {api_key: "abc123"})
    query = Geocoder::Query.new("Leadville, CO")
    assert_equal "https://api.mapbox.com/geocoding/v5/mapbox.places/Leadville%2C+CO.json?access_token=abc123", query.url
  end

  def test_url_contains_params
    Geocoder.configure(mapbox: {api_key: "abc123"})
    query = Geocoder::Query.new("Leadville, CO", {params: {country: 'CN'}})
    assert_equal "https://api.mapbox.com/geocoding/v5/mapbox.places/Leadville%2C+CO.json?access_token=abc123&country=CN", query.url
  end

  def test_result_components
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal [40.750755, -73.993710125], result.coordinates
    assert_equal "Madison Square Garden", result.place_name
    assert_equal "4 Penn Plz", result.street
    assert_equal "New York", result.city
    assert_equal "New York", result.state
    assert_equal "10119", result.postal_code
    assert_equal "NY", result.state_code
    assert_equal "United States", result.country
    assert_equal "US", result.country_code
    assert_equal "Garment District", result.neighborhood
    assert_equal "Madison Square Garden, 4 Penn Plz, New York, New York, 10119, United States", result.address
  end

  def test_no_results
    assert_equal [], Geocoder.search("no results")
  end

  def test_raises_exception_with_invalid_api_key
    Geocoder.configure(always_raise: [Geocoder::InvalidApiKey])
    assert_raises Geocoder::InvalidApiKey do
      Geocoder.search("invalid api key")
    end
  end

  def test_truncates_query_at_semicolon
    result = Geocoder.search("Madison Square Garden, New York, NY;123 Another St").first
    assert_equal [40.750755, -73.993710125], result.coordinates
  end

  def test_mapbox_result_without_context
    assert_nothing_raised do
      result = Geocoder.search("Shanghai, China")[0]
      assert_equal nil, result.city
    end
  end
end
