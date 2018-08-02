# encoding: utf-8
require 'test_helper'

class Ip2locationLiteTest < GeocoderTestCase
  def setup
    Geocoder.configure(ip_lookup: :ip2location_lite, ip2location_lite: { file: File.join('folder', 'test_file') })
  end

  def test_result_attributes
    result = Geocoder.search('8.8.8.8').first
    assert_equal 'US', result.country_short
    assert_equal 'United States', result.country_long
    assert_equal 'California', result.region
    assert_equal 'Mountain View', result.city
    assert_equal 37.40599060058594, result.latitude
    assert_equal(-122.0785140991211, result.longitude)
    assert_equal '94043', result.zipcode
    assert_equal '-07:00', result.timezone
  end

  def test_loopback
    result = Geocoder.search('127.0.0.1').first
    assert_equal '-', result.country_short
    assert_equal '-', result.region
    assert_equal '-', result.city
  end
end
