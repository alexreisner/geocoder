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
    assert_equal "https://api.mapbox.com/geocoding/v5/mapbox.places/Leadville%2C%20CO.json?access_token=abc123", query.url
  end

  def test_url_contains_params
    Geocoder.configure(mapbox: {api_key: "abc123"})
    query = Geocoder::Query.new("Leadville, CO", {params: {country: 'CN'}})
    assert_equal "https://api.mapbox.com/geocoding/v5/mapbox.places/Leadville%2C%20CO.json?access_token=abc123&country=CN", query.url
  end

  def test_result_components
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal [40.750755, -73.993710125], result.coordinates
    assert_equal "Madison Square Garden, 4 Penn Plz, New York, New York 10119, United States", result.place_name
    assert_equal "4 Penn Plz", result.street
    assert_equal "New York", result.city
    assert_equal "New York", result.state
    assert_equal "10119", result.postal_code
    assert_equal "NY", result.state_code
    assert_equal "United States", result.country
    assert_equal "US", result.country_code
    assert_equal "Garment District", result.neighborhood
    assert_equal "Madison Square Garden, 4 Penn Plz, New York, New York 10119, United States", result.address
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

  def test_empty_array_on_invalid_api_key
    assert_equal [], Geocoder.search("invalid api key")
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

  def test_neighborhood_result
    result = Geocoder.search("Logan Square, Chicago, IL").first
    assert_equal [41.92597, -87.70235], result.coordinates
    assert_equal "Logan Square, Chicago, Illinois, United States", result.place_name
    assert_equal nil, result.street
    assert_equal "Chicago", result.city
    assert_equal "Illinois", result.state
    assert_equal "60647", result.postal_code
    assert_equal "IL", result.state_code
    assert_equal "United States", result.country
    assert_equal "US", result.country_code
    assert_equal "Logan Square", result.neighborhood
    assert_equal "Logan Square, Chicago, Illinois, United States", result.address
  end

  def test_postcode_result
    result = Geocoder.search("Chicago, IL 60647").first
    assert_equal [41.924799, -87.700436], result.coordinates
    assert_equal "Chicago, Illinois 60647, United States", result.place_name
    assert_equal nil, result.street
    assert_equal "Chicago", result.city
    assert_equal "Illinois", result.state
    assert_equal "60647", result.postal_code
    assert_equal "IL", result.state_code
    assert_equal "United States", result.country
    assert_equal "US", result.country_code
    assert_equal nil, result.neighborhood
    assert_equal "Chicago, Illinois 60647, United States", result.address
  end

  def test_place_result
    result = Geocoder.search("Chicago, IL").first
    assert_equal [41.881954, -87.63236], result.coordinates
    assert_equal "Chicago, Illinois, United States", result.place_name
    assert_equal nil, result.street
    assert_equal "Chicago", result.city
    assert_equal "Illinois", result.state
    assert_equal nil, result.postal_code
    assert_equal "IL", result.state_code
    assert_equal "United States", result.country
    assert_equal "US", result.country_code
    assert_equal nil, result.neighborhood
    assert_equal "Chicago, Illinois, United States", result.address
  end

  def test_region_result
    result = Geocoder.search("Illinois").first
    assert_equal [40.1492928594374, -89.2749461071049], result.coordinates
    assert_equal "Illinois, United States", result.place_name
    assert_equal nil, result.street
    assert_equal nil, result.city
    assert_equal "Illinois", result.state
    assert_equal nil, result.postal_code
    assert_equal "IL", result.state_code
    assert_equal "United States", result.country
    assert_equal "US", result.country_code
    assert_equal nil, result.neighborhood
    assert_equal "Illinois, United States", result.address
  end

  def test_country_result
    result = Geocoder.search("United States").first
    assert_equal [39.3812661305678, -97.9222112121185], result.coordinates
    assert_equal "United States", result.place_name
    assert_equal nil, result.street
    assert_equal nil, result.city
    assert_equal nil, result.state
    assert_equal nil, result.postal_code
    assert_equal nil, result.state_code
    assert_equal "United States", result.country
    assert_equal "US", result.country_code
    assert_equal nil, result.neighborhood
    assert_equal "United States", result.address
  end
end
