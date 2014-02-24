# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class MaxmindLocalTest < GeocoderTestCase

  def setup
    Geocoder.configure(ip_lookup: :maxmind_local)
  end

  def test_result_attributes
    result = Geocoder.search('8.8.8.8').first
    assert_equal result.address, 'Mountain View, CA 94043, United States'
    assert_equal result.city, 'Mountain View'
    assert_equal result.state, 'CA'
    assert_equal result.country, 'United States'
    assert_equal result.country_code, 'USA'
    assert_equal result.postal_code, '94043'
    assert_equal result.latitude, 37.41919999999999
    assert_equal result.longitude, -122.0574
  end

  def test_loopback
    results = Geocoder.search('127.0.0.1')
    assert_equal [], results
  end
end
