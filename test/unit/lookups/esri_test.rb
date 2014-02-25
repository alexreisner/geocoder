# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

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
    assert_equal(40.75004981300049, result.coordinates[0])
    assert_equal(-73.99423889799965, result.coordinates[1])
  end

  def test_results_component_when_reverse_geocoding
    result = Geocoder.search([45.423733, -75.676333]).first
    assert_equal "75007", result.postal_code
    assert_equal "FRA", result.country
    assert_equal "4 Avenue Gustave Eiffel", result.address
    assert_equal "Paris", result.city
    assert_equal "Île-de-France", result.state
    assert_equal(48.858129997357558, result.coordinates[0])
    assert_equal(2.2956200048981574, result.coordinates[1])
  end
end
