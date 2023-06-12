# encoding: utf-8
require 'test_helper'

class TrimbleMapsTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(lookup: :pc_miler)
  end

  def test_query_for_geocode
    query = Geocoder::Query.new('wall drug')
    lookup = Geocoder::Lookup.get(:pc_miler)
    res = lookup.query_url(query)
    assert_equal 'https://singlesearch.alk.com/NA/api/search?include=Meta&query=wall%2Bdrug', res
  end

  def test_query_for_reverse_geocode
    query = Geocoder::Query.new([43.99255, -102.24127])
    lookup = Geocoder::Lookup.get(:pc_miler)
    res = lookup.query_url(query)
    assert_equal 'https://singlesearch.alk.com/NA/api/search?include=Meta&query=43.99255%2C-102.24127', res
  end

  def test_not_authorized
    Geocoder.configure(always_raise: [Geocoder::RequestDenied])
    lookup = Geocoder::Lookup.get(:pc_miler)
    assert_raises Geocoder::RequestDenied do
      response = MockHttpResponse.new(code: 403)
      lookup.send(:check_response_for_errors!, response)
    end
  end

  def test_query_region_defaults_to_north_america
    query = Geocoder::Query.new('Sydney')
    lookup = Geocoder::Lookup.get(:pc_miler)
    res = lookup.query_url(query)
    assert_equal 'https://singlesearch.alk.com/NA/api/search?include=Meta&query=Sydney', res
  end

  def test_query_region_can_be_given_in_global_config
    Geocoder.configure(lookup: :pc_miler, pc_miler: { region: 'EU' })
    query = Geocoder::Query.new('Sydney')
    lookup = Geocoder::Lookup.get(:pc_miler)
    res = lookup.query_url(query)
    assert_equal 'https://singlesearch.alk.com/EU/api/search?include=Meta&query=Sydney', res
  end

  # option given in query takes precedence over global option
  def test_query_region_can_be_given_in_query
    Geocoder.configure(lookup: :pc_miler, pc_miler: { region: 'EU' })
    query = Geocoder::Query.new('Sydney', region: 'OC')
    lookup = Geocoder::Lookup.get(:pc_miler)
    res = lookup.query_url(query)
    assert_equal 'https://singlesearch.alk.com/OC/api/search?include=Meta&query=Sydney', res
  end

  def test_query_raises_if_region_is_invalid
    query = Geocoder::Query.new('Sydney', region: 'QQ')
    lookup = Geocoder::Lookup.get(:pc_miler)

    error = assert_raises do
      lookup.query_url(query)
    end

    assert_match /region_code 'QQ' is invalid/, error.message
  end

  def test_results_with_street_address
    results = Geocoder.search('wall drug')

    assert_equal 2, results.size

    result = results[0]

    assert_equal '510 Main St', result.street
    assert_equal 'Wall', result.city
    assert_equal 'South Dakota', result.state
    assert_equal 'SD', result.state_code
    assert_equal '57790-9501', result.postal_code
    assert_equal 'United States', result.country
    assert_equal 'US', result.country_code
    assert_equal '510 Main St, Wall, South Dakota, 57790-9501, United States', result.address
    assert_equal 44.0632, result.latitude
    assert_equal -102.2151, result.longitude
    assert_equal([44.0632, -102.2151], result.coordinates)
  end

  def test_results_without_street_address
    results = Geocoder.search('Duluth MN')

    assert_equal 1, results.size

    result = results[0]

    assert_equal '', result.street
    assert_equal 'Duluth', result.city
    assert_equal 'Minnesota', result.state
    assert_equal 'MN', result.state_code
    assert_equal '55806', result.postal_code
    assert_equal 'United States', result.country
    assert_equal 'US', result.country_code
    assert_equal 'Duluth, Minnesota, 55806, United States', result.address
    assert_equal 46.776443, result.latitude
    assert_equal -92.110529, result.longitude
    assert_equal([46.776443, -92.110529], result.coordinates)
  end

  def test_results_reverse_geocoding
    results = Geocoder.search([42.14228, -102.85796])

    assert_equal 1, results.size

    result = results[0]

    assert_equal '2093 NE-87', result.street
    assert_equal 'Alliance', result.city
    assert_equal 'Nebraska', result.state
    assert_equal 'NE', result.state_code
    assert_equal '69301', result.postal_code
    assert_equal 'United States', result.country
    assert_equal 'US', result.country_code
    assert_equal '2093 NE-87, Alliance, Nebraska, 69301, United States', result.address
    assert_equal 42.14228, result.latitude
    assert_equal -102.85796, result.longitude
    assert_equal([42.14228, -102.85796], result.coordinates)
  end
end
