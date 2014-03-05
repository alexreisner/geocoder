# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class MaxmindLocalTest < GeocoderTestCase

  def setup
    Geocoder.configure(ip_lookup: :maxmind_local)
  end

  def test_result_attributes
    result = Geocoder.search('8.8.8.8').first
    assert_equal 'Mountain View, CA 94043, United States', result.address
    assert_equal 'Mountain View', result.city
    assert_equal 'CA', result.state
    assert_equal 'United States', result.country
    assert_equal 'USA', result.country_code
    assert_equal '94043', result.postal_code
    assert_equal 37.41919999999999, result.latitude
    assert_equal -122.0574, result.longitude
  end

  def test_loopback
    results = Geocoder.search('127.0.0.1')
    assert_equal [], results
  end
end
