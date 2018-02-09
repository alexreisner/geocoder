# encoding: utf-8
require 'test_helper'

class OsmnamesTest < GeocoderTestCase
  def setup
    Geocoder.configure(lookup: :osmnames)
    set_api_key!(:osmnames)
  end

  def test_url_contains_api_key
    Geocoder.configure(osmnames: {api_key: 'abc123'})
    query = Geocoder::Query.new('test')
    assert_includes query.url, 'key=abc123'
  end

  def test_url_contains_query_base
    query = Geocoder::Query.new("Madison Square Garden, New York, NY")
    assert_includes query.url, 'https://geocoder.tilehosting.com/q/Madison%20Square%20Garden,%20New%20York,%20NY.js'
  end

  def test_url_contains_country_code
    query = Geocoder::Query.new("test", country_code: 'US')
    assert_includes query.url, 'https://geocoder.tilehosting.com/us/q/'
  end

  def test_result_components
    result = Geocoder.search('Madison Square Garden, New York, NY').first
    assert_equal [40.693073, -73.878418], result.coordinates
    assert_equal 'New York City, New York, United States of America', result.address
    assert_equal 'New York', result.state
    assert_equal 'New York City', result.city
    assert_equal 'us', result.country_code
  end

  def test_result_for_reverse_geocode
    result = Geocoder.search('-73.878418, 40.693073').first
    assert_equal 'New York City, New York, United States of America', result.address
    assert_equal 'New York', result.state
    assert_equal 'New York City', result.city
    assert_equal 'us', result.country_code
  end

  def test_url_for_reverse_geocode
    query = Geocoder::Query.new("-73.878418, 40.693073")
    assert_includes query.url, 'https://geocoder.tilehosting.com/r/-73.878418/40.693073.js'
  end

  def test_result_viewport
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal [40.477398, -74.259087, 40.91618, -73.70018], result.viewport
  end

  def test_no_results
    assert_equal [], Geocoder.search("no results")
  end

  def test_raises_exception_when_return_message_error
    Geocoder.configure(always_raise: [Geocoder::InvalidRequest])
    assert_raises Geocoder::InvalidRequest.new("Invalid attribute value.") do
      Geocoder.search("invalid request")
    end
  end
end
