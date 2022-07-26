# frozen_string_literal: true

require 'test_helper'

# Test for Photon
class PhotonTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(lookup: :photon)
  end

  def test_photon_forward_geocoding_result_properties
    result = Geocoder.search('Madison Square Garden, New York, NY').first

    geometry = { type: 'Point', coordinates: [-73.99355027800776, 40.7505247] }
    bounds = [-73.9944446, 40.751161, -73.9925924, 40.7498531]

    assert_equal(40.7505247, result.latitude)
    assert_equal(-73.99355027800776, result.longitude)
    assert_equal '4 Pennsylvania Plaza', result.street_address
    assert_equal 'Madison Square Garden, 4 Pennsylvania Plaza, New York, New York, 10001, United States of America',
                 result.address
    assert_equal '4', result.house_number
    assert_equal 'Pennsylvania Plaza', result.street
    assert_equal geometry, result.geometry
    assert_equal bounds, result.bounds
    assert_equal :way, result.type
    assert_equal 138_141_251, result.osm_id
    assert_equal 'leisure=stadium', result.osm_tag
  end

  def test_photon_reverse_geocoding_result_properties
    result = Geocoder.search([45.423733, -75.676333]).first

    geometry = { type: 'Point', coordinates: [-73.9935078, 40.750499] }

    assert_equal(40.750499, result.latitude)
    assert_equal(-73.9935078, result.longitude)
    assert_equal '4 Pennsylvania Plaza', result.street_address
    assert_equal '4 Pennsylvania Plaza, New York, New York, 10121, United States of America',
                 result.address
    assert_equal '4', result.house_number
    assert_equal 'Pennsylvania Plaza', result.street
    assert_equal geometry, result.geometry
    assert_nil result.bounds
    assert_equal :node, result.type
    assert_equal 6_985_936_386, result.osm_id
    assert_equal 'tourism=attraction', result.osm_tag
  end

  def test_photon_query_url_contains_language
    lookup = Geocoder::Lookup::Photon.new
    url = lookup.query_url(
      Geocoder::Query.new(
        'Test Query',
        language: 'de'
      )
    )
    assert_match(/lang=de/, url)
  end

  def test_photon_query_url_contains_limit
    lookup = Geocoder::Lookup::Photon.new
    url = lookup.query_url(
      Geocoder::Query.new(
        'Test Query',
        limit: 5
      )
    )
    assert_match(/limit=5/, url)
  end

  def test_photon_query_url_contains_query
    lookup = Geocoder::Lookup::Photon.new
    url = lookup.query_url(
      Geocoder::Query.new(
        'Test Query'
      )
    )
    assert_match(/q=Test\+Query/, url)
  end

  def test_photon_query_url_contains_params
    lookup = Geocoder::Lookup::Photon.new
    url = lookup.query_url(
      Geocoder::Query.new(
        'Test Query',
        bias: {
          latitude: 45.423733,
          longitude: -75.676333,
          scale: 4
        },
        filter: {
          bbox: [-73.9944446, 40.751161, -73.9925924, 40.7498531],
          osm_tag: 'leisure:stadium'
        }
      )
    )
    assert_match(/q=Test\+Query/, url)
    assert_match(/lat=45\.423733/, url)
    assert_match(/lon=-75\.676333/, url)
    assert_match(/bbox=-73\.9944446%2C40\.751161%2C-73\.9925924%2C40\.7498531/, url)
    assert_match(/osm_tag=leisure%3Astadium/, url)
  end

  def test_photon_reverse_query_url_contains_lat_lon
    lookup = Geocoder::Lookup::Photon.new
    url = lookup.query_url(
      Geocoder::Query.new(
        [45.423733, -75.676333]
      )
    )
    assert_no_match(/q=.*/, url)
    assert_match(/lat=45\.423733/, url)
    assert_match(/lon=-75\.676333/, url)
  end

  def test_photon_reverse_query_url_contains_params
    lookup = Geocoder::Lookup::Photon.new
    url = lookup.query_url(
      Geocoder::Query.new(
        [45.423733, -75.676333],
        radius: 5,
        distance_sort: true,
        filter: {
          string: 'query string filter'
        }
      )
    )
    assert_no_match(/q=.*/, url)
    assert_match(/lat=45\.423733/, url)
    assert_match(/lon=-75\.676333/, url)
    assert_match(/radius=5/, url)
    assert_match(/distance_sort=true/, url)
    assert_match(/query_string_filter=query\+string\+filter/, url)
  end

  def test_photon_invalid_request
    Geocoder.configure(always_raise: [Geocoder::InvalidRequest])
    assert_raises Geocoder::InvalidRequest do
      Geocoder.search('invalid request')
    end
  end
end
