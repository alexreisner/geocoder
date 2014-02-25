# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class MapquestTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :mapquest)
    set_api_key!(:mapquest)
  end

  def test_url_contains_api_key
    Geocoder.configure(mapquest: {api_key: "abc123"})
    query = Geocoder::Query.new("Bluffton, SC")
    assert_equal "http://www.mapquestapi.com/geocoding/v1/address?key=abc123&location=Bluffton%2C+SC", query.url
  end

  def test_url_for_version_2
    Geocoder.configure(mapquest: {api_key: "abc123", version: 2})
    query = Geocoder::Query.new("Bluffton, SC")
    assert_equal "http://www.mapquestapi.com/geocoding/v2/address?key=abc123&location=Bluffton%2C+SC", query.url
  end

  def test_url_for_open_street_maps
    Geocoder.configure(mapquest: {api_key: "abc123", open: true})
    query = Geocoder::Query.new("Bluffton, SC")
    assert_equal "http://open.mapquestapi.com/geocoding/v1/address?key=abc123&location=Bluffton%2C+SC", query.url
  end

  def test_result_components
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "10001", result.postal_code
    assert_equal "46 West 31st Street, New York, NY, 10001, US", result.address
  end

  def test_no_results
    assert_equal [], Geocoder.search("no results")
  end

  def test_raises_exception_when_invalid_request
    Geocoder.configure(always_raise: [Geocoder::InvalidRequest])
    assert_raises Geocoder::InvalidRequest do
      Geocoder.search("invalid request")
    end
  end

  def test_raises_exception_when_invalid_api_key
    Geocoder.configure(always_raise: [Geocoder::InvalidApiKey])
    assert_raises Geocoder::InvalidApiKey do
      Geocoder.search("invalid api key")
    end
  end

  def test_raises_exception_when_error
    Geocoder.configure(always_raise: [Geocoder::Error])
    assert_raises Geocoder::Error do
      Geocoder.search("error")
    end
  end
end
