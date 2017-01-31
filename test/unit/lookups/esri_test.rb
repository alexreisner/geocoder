# encoding: utf-8
require 'test_helper'
require 'geocoder/esri_token'

class EsriTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :esri)
  end

  def test_query_for_geocode
    query = Geocoder::Query.new("Bluffton, SC")
    lookup = Geocoder::Lookup.get(:esri)
    res = lookup.query_url(query)
    assert_equal "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/find?f=pjson&outFields=%2A&text=Bluffton%2C+SC",
      res
  end

  def test_query_for_geocode_with_source_country
    Geocoder.configure(esri: {source_country: 'USA'})
    query = Geocoder::Query.new("Bluffton, SC")
    lookup = Geocoder::Lookup.get(:esri)
    url = lookup.query_url(query)
    assert_match %r{sourceCountry=USA}, url
  end

  def test_query_for_geocode_with_token_and_for_storage
    token = Geocoder::EsriToken.new('xxxxx', Time.now + 60*60*24)
    Geocoder.configure(esri: {token: token, for_storage: true})
    query = Geocoder::Query.new("Bluffton, SC")
    lookup = Geocoder::Lookup.get(:esri)
    url = lookup.query_url(query)
    assert_match %r{forStorage=true}, url
    assert_match %r{token=xxxxx}, url
  end

  def test_token_generation_doesnt_overwrite_existing_config
    Geocoder.configure(esri: {api_key: ['id','secret'], for_storage: true})

    query = Geocoder::Query.new("Bluffton, SC")
    lookup = Geocoder::Lookup.get(:esri)

    lookup.instance_eval do
      # redefine `create_token` to return a manually-created token
      def create_token
        "xxxxx"
      end
    end

    url = lookup.query_url(query)

    assert_match %r{forStorage=true}, url
    assert_match %r{token=xxxxx}, url
  end

  def test_query_for_reverse_geocode
    query = Geocoder::Query.new([45.423733, -75.676333])
    lookup = Geocoder::Lookup.get(:esri)
    res = lookup.query_url(query)
    assert_equal "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?f=pjson&location=-75.676333%2C45.423733&outFields=%2A",
      res
  end

  def test_results_component
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "10001", result.postal_code
    assert_equal "USA", result.country
    assert_equal "Madison Square Garden", result.address
    assert_equal "New York", result.city
    assert_equal "New York", result.state
    assert_equal "Madison Square Garden", result.place_name
    assert_equal "Sports Complex", result.place_type
    assert_equal(40.75004981300049, result.coordinates[0])
    assert_equal(-73.99423889799965, result.coordinates[1])
  end

  def test_results_component_when_location_type_is_national_capital
    result = Geocoder.search("washington dc").first
    assert_equal "Washington", result.city
    assert_equal "District of Columbia", result.state
    assert_equal "USA", result.country
    assert_equal "Washington, D. C., District of Columbia, United States", result.address
    assert_equal "Washington", result.place_name
    assert_equal "National Capital", result.place_type
    assert_equal(38.895107833000452, result.coordinates[0])
    assert_equal(-77.036365517999627, result.coordinates[1])
  end

  def test_results_component_when_location_type_is_state_capital
    result = Geocoder.search("austin tx").first
    assert_equal "Austin", result.city
    assert_equal "Texas", result.state
    assert_equal "USA", result.country
    assert_equal "Austin, Texas, United States", result.address
    assert_equal "Austin", result.place_name
    assert_equal "State Capital", result.place_type
    assert_equal(30.267145960000448, result.coordinates[0])
    assert_equal(-97.743055550999657, result.coordinates[1])
  end

  def test_results_component_when_location_type_is_city
    result = Geocoder.search("new york ny").first
    assert_equal "New York City", result.city
    assert_equal "New York", result.state
    assert_equal "USA", result.country
    assert_equal "New York City, New York, United States", result.address
    assert_equal "New York City", result.place_name
    assert_equal "City", result.place_type
    assert_equal(40.714269404000447, result.coordinates[0])
    assert_equal(-74.005969928999662, result.coordinates[1])
  end

  def test_results_component_when_reverse_geocoding
    result = Geocoder.search([45.423733, -75.676333]).first
    assert_equal "75007", result.postal_code
    assert_equal "FRA", result.country
    assert_equal "4 Avenue Gustave Eiffel", result.address
    assert_equal "Paris", result.city
    assert_equal "Île-de-France", result.state
    assert_equal "4 Avenue Gustave Eiffel", result.place_name
    assert_equal "Address", result.place_type
    assert_equal(48.858129997357558, result.coordinates[0])
    assert_equal(2.2956200048981574, result.coordinates[1])
  end

  def test_results_viewport
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal [40.744050000000001, -74.000241000000003, 40.756050000000002, -73.988241000000002],
      result.viewport
  end

  def test_cache_key_doesnt_include_api_key_or_token
    token = Geocoder::EsriToken.new('xxxxx', Time.now + 60)
    Geocoder.configure(esri: {token: token, api_key: "xxxxx", for_storage: true})
    query = Geocoder::Query.new("Bluffton, SC")
    lookup = Geocoder::Lookup.get(:esri)
    key = lookup.send(:cache_key, query)
    assert_match %r{forStorage}, key
    assert_no_match %r{token}, key
    assert_no_match %r{api_key}, key
  end

  def teardown
    Geocoder.configure(esri: {token: nil, for_storage: nil})
  end
end
