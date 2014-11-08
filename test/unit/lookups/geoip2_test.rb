# encoding: utf-8
require 'test_helper'

class Geoip2Test < GeocoderTestCase
  def setup
    Geocoder.configure(ip_lookup: :geoip2, file: 'test_file')
  end

  def test_result_attributes
    result = Geocoder.search('8.8.8.8').first
    assert_equal 'Mountain View, CA 94043, United States', result.address
    assert_equal 'Mountain View', result.city
    assert_equal 'CA', result.state_code
    assert_equal 'California', result.state
    assert_equal 'United States', result.country
    assert_equal 'US', result.country_code
    assert_equal '94043', result.postal_code
    assert_equal 37.41919999999999, result.latitude
    assert_equal -122.0574, result.longitude
    assert_equal [37.41919999999999, -122.0574], result.coordinates
  end

  def test_loopback
    results = Geocoder.search('127.0.0.1')
    assert_equal [], results
  end
end
