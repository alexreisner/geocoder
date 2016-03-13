# encoding: utf-8
require 'test_helper'

class GeoportailLuTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :geoportail_lu)
  end

  def test_query_for_geocode
    query = Geocoder::Query.new('55 route de luxembourg, pontpierre')
    lookup = Geocoder::Lookup.get(:geoportail_lu)
    res = lookup.query_url(query)
    assert_equal 'http://api.geoportail.lu/geocoder/search?queryString=55+route+de+luxembourg%2C+pontpierre', res
  end

  def test_query_for_reverse_geocode
    query = Geocoder::Query.new([45.423733, -75.676333])
    lookup = Geocoder::Lookup.get(:geoportail_lu)
    res = lookup.query_url(query)
    assert_equal 'http://api.geoportail.lu/geocoder/reverseGeocode?lat=45.423733&lon=-75.676333', res
  end

  def test_results_component
    result = Geocoder.search('2 boulevard Royal, luxembourg').first
    assert_equal '2449', result.postal_code
    assert_equal 'Luxembourg', result.country
    assert_equal '2 Boulevard Royal,2449 Luxembourg', result.address
    assert_equal '2', result.street_number
    assert_equal 'Boulevard Royal', result.street
    assert_equal '2 Boulevard Royal', result.street_address
    assert_equal 'Luxembourg', result.city
    assert_equal 'Luxembourg', result.state
    assert_country_code result
    assert_equal(49.6146720749933, result.coordinates[0])
    assert_equal(6.12939750216249, result.coordinates[1])
  end

  def test_results_component_when_reverse_geocoding
    result = Geocoder.search([6.12476867352074, 49.6098566608772]).first
    assert_equal '1724', result.postal_code
    assert_equal 'Luxembourg', result.country
    assert_equal '39 Boulevard Prince Henri,1724 Luxembourg', result.address
    assert_equal '39', result.street_number
    assert_equal 'Boulevard Prince Henri', result.street
    assert_equal '39 Boulevard Prince Henri', result.street_address
    assert_equal 'Luxembourg', result.city
    assert_equal 'Luxembourg', result.state
    assert_country_code result
    assert_equal(49.6098566608772, result.coordinates[0])
    assert_equal(6.12476867352074, result.coordinates[1])
  end

  def test_no_results
    results = Geocoder.search('')
    assert_equal 0, results.length
  end

  private

  def assert_country_code(result)
    [:state_code, :country_code, :province_code].each do |method|
      assert_equal 'LU', result.send(method)
    end
  end
end
