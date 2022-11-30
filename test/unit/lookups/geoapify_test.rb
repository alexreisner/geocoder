# frozen_string_literal: true

require 'test_helper'

class GeoapifyTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(lookup: :geoapify)
    set_api_key!(:geoapify)
  end

  def test_geoapify_forward_geocoding_result_properties
    result = Geocoder.search('Madison Square Garden, New York, NY').first

    geometry = { type: 'Point', coordinates: [-73.993368, 40.750487] }
    bounds = [-73.9944446, 40.7498531, -73.9925924, 40.751161]
    rank = { popularity: 8.615793062435909, confidence: 1, match_type: :full_match }
    datasource = {
      sourcename: 'openstreetmap',
      wheelchair: 'limited',
      wikidata: 'Q186125',
      wikipedia: 'en:Madison Square Garden',
      website: 'http://www.thegarden.com/',
      phone: '12124656741',
      osm_type: 'W',
      osm_id: 138_141_251,
      continent: 'North America'
    }

    assert_equal(40.750487, result.latitude)
    assert_equal(-73.993368, result.longitude)
    assert_equal '4 Pennsylvania Plaza', result.address_line1
    assert_equal 'New York, NY 10001, United States of America', result.address_line2
    assert_equal '4', result.house_number
    assert_equal 'Pennsylvania Plaza', result.street
    assert_equal 'Manhattan', result.district
    assert_equal 'Chelsea', result.suburb
    assert_equal 'New York County', result.county
    assert_equal geometry, result.geometry
    assert_equal bounds, result.bounds
    assert_equal :building, result.type
    assert_nil result.distance # Only for reverse geocoding requests
    assert_equal rank, result.rank
    assert_equal datasource, result.datasource
  end

  def test_geoapify_reverse_geocoding_result_properties
    result = Geocoder.search([45.423733, -75.676333]).first

    geometry = { type: 'Point', coordinates: [-73.993368, 40.750487] }
    bounds = [-73.9944446, 40.7498531, -73.9925924, 40.751161]
    rank = { popularity: 8.615793062435909 }
    datasource = {
      sourcename: 'openstreetmap',
      wheelchair: 'limited',
      wikidata: 'Q186125',
      wikipedia: 'en:Madison Square Garden',
      website: 'http://www.thegarden.com/',
      phone: '12124656741',
      osm_type: 'W',
      osm_id: 138_141_251,
      continent: 'North America'
    }

    assert_equal(40.750487, result.latitude)
    assert_equal(-73.993368, result.longitude)
    assert_equal 'Madison Square Garden', result.address_line1
    assert_equal '4 Pennsylvania Plaza, New York, NY 10001, United States of America', result.address_line2
    assert_equal '4', result.house_number
    assert_equal 'Pennsylvania Plaza', result.street
    assert_equal 'Manhattan', result.district
    assert_equal 'Chelsea', result.suburb
    assert_equal 'New York County', result.county
    assert_equal geometry, result.geometry
    assert_equal bounds, result.bounds
    assert_equal :amenity, result.type
    assert_equal 14.791104652930729, result.distance
    assert_equal rank, result.rank
    assert_equal datasource, result.datasource
  end

  def test_geoapify_query_url_contains_language
    lookup = Geocoder::Lookup::Geoapify.new
    url = lookup.query_url(
      Geocoder::Query.new(
        'Test Query',
        language: 'de'
      )
    )
    assert_match(/lang=de/, url)
  end

  def test_geoapify_query_url_contains_limit
    lookup = Geocoder::Lookup::Geoapify.new
    url = lookup.query_url(
      Geocoder::Query.new(
        'Test Query',
        limit: 5
      )
    )
    assert_match(/limit=5/, url)
  end

  def test_geoapify_query_url_contains_api_key
    lookup = Geocoder::Lookup::Geoapify.new
    url = lookup.query_url(
      Geocoder::Query.new(
        'Test Query'
      )
    )
    assert_match(/apiKey=a+/, url)
  end

  def test_geoapify_query_url_contains_text
    lookup = Geocoder::Lookup::Geoapify.new
    url = lookup.query_url(
      Geocoder::Query.new(
        'Test Query'
      )
    )
    assert_match(/text=Test\+Query/, url)
  end

  def test_geoapify_query_url_contains_params
    lookup = Geocoder::Lookup::Geoapify.new
    url = lookup.query_url(
      Geocoder::Query.new(
        'Test Query',
        params: {
          type: 'amenity',
          filter: 'countrycode:us',
          bias: 'countrycode:us'
        }
      )
    )
    assert_match(/bias=countrycode%3Aus/, url)
    assert_match(/filter=countrycode%3Aus/, url)
    assert_match(/type=amenity/, url)
  end

  def test_geoapify_reverse_query_url_contains_lat_lon
    lookup = Geocoder::Lookup::Geoapify.new
    url = lookup.query_url(
      Geocoder::Query.new(
        [45.423733, -75.676333]
      )
    )
    assert_match(/lat=45\.423733/, url)
    assert_match(/lon=-75\.676333/, url)
  end

  def test_geoapify_query_url_contains_autocomplete
    lookup = Geocoder::Lookup::Geoapify.new
    url = lookup.query_url(
      Geocoder::Query.new(
        'Test Query',
        autocomplete: true
      )
    )
    assert_match(/\/geocode\/autocomplete/, url)
  end

  def test_geoapify_invalid_request
    Geocoder.configure(always_raise: [Geocoder::InvalidRequest])
    assert_raises Geocoder::InvalidRequest do
      Geocoder.search('invalid request')
    end
  end

  def test_geoapify_invalid_key
    Geocoder.configure(always_raise: [Geocoder::RequestDenied])
    assert_raises Geocoder::RequestDenied do
      Geocoder.search('invalid key')
    end
  end
end
