# encoding: utf-8
require 'test_helper'
require 'logger'
require 'tempfile'

class MapboxTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(lookup: :mapbox)
    set_api_key!(:mapbox)
  end

  def test_url_contains_api_key
    Geocoder.configure(mapbox: {api_key: "abc123"})
    query = Geocoder::Query.new("Leadville, CO")
    assert_equal "https://api.mapbox.com/search/geocode/v6/forward?access_token=abc123&q=Leadville%2C+CO", query.url
  end

  def test_url_contains_params
    Geocoder.configure(mapbox: {api_key: "abc123"})
    query = Geocoder::Query.new("Leadville, CO", {params: {country: 'CN'}})
    assert_equal "https://api.mapbox.com/search/geocode/v6/forward?access_token=abc123&country=CN&q=Leadville%2C+CO", query.url
  end

  def test_reverse_url_contains_lon_lat_params
    Geocoder.configure(mapbox: {api_key: "abc123"})
    query = Geocoder::Query.new([40.750755, -73.993710125])
    assert_equal "https://api.mapbox.com/search/geocode/v6/reverse?access_token=abc123&latitude=40.750755&longitude=-73.993710125", query.url
  end

  def test_permanent_dataset_is_translated_into_permanent_param
    Geocoder.configure(logger: Logger.new(Tempfile.new("log").path), mapbox: {api_key: "abc123", dataset: "mapbox.places-permanent"})
    query = Geocoder::Query.new("Leadville, CO")
    assert_equal "https://api.mapbox.com/search/geocode/v6/forward?access_token=abc123&permanent=true&q=Leadville%2C+CO", query.url
  end

  def test_permanent_dataset_logs_deprecation_warning
    tempfile = Tempfile.new("log")
    Geocoder.configure(logger: Logger.new(tempfile.path), mapbox: {api_key: "abc123", dataset: "mapbox.places-permanent"})
    Geocoder::Query.new("Leadville, CO").url
    assert_match(/DEPRECATION WARNING: the Mapbox :dataset option/, tempfile.read)
  end

  def test_default_dataset_does_not_send_permanent_param
    Geocoder.configure(mapbox: {api_key: "abc123", dataset: "mapbox.places"})
    query = Geocoder::Query.new("Leadville, CO")
    assert_equal "https://api.mapbox.com/search/geocode/v6/forward?access_token=abc123&q=Leadville%2C+CO", query.url
  end

  def test_result_components
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal [40.750755, -73.993710125], result.coordinates
    assert_equal "4 Pennsylvania Plaza, New York, New York 10119, United States", result.place_name
    assert_equal "4 Pennsylvania Plaza", result.street
    assert_equal "New York", result.city
    assert_equal "New York County", result.county
    assert_equal "New York", result.state
    assert_equal "10119", result.postal_code
    assert_equal "NY", result.state_code
    assert_equal "United States", result.country
    assert_equal "US", result.country_code
    assert_equal "Garment District", result.neighborhood
    assert_equal "4 Pennsylvania Plaza, New York, New York 10119, United States", result.address
  end

  def test_country_result
    result = Geocoder.search("United States").first
    assert_equal [39.3812661305678, -97.9222112121185], result.coordinates
    assert_equal "United States", result.place_name
    assert_equal nil, result.street
    assert_equal nil, result.city
    assert_equal nil, result.county
    assert_equal nil, result.state
    assert_equal nil, result.postal_code
    assert_equal nil, result.state_code
    assert_equal "United States", result.country
    assert_equal "US", result.country_code
    assert_equal nil, result.neighborhood
    assert_equal "United States", result.address
  end

  def test_address_precision
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "rooftop", result.precision
  end

  def test_country_result_precision
    result = Geocoder.search("United States").first
    assert_equal nil, result.precision
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
end
