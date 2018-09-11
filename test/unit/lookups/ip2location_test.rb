# encoding: utf-8
require 'test_helper'

class Ip2locationTest < GeocoderTestCase

  def setup
    Geocoder.configure(:ip_lookup => :ip2location)
  end

  def test_ip2location_lookup_address
    result = Geocoder.search("8.8.8.8").first
    assert_equal "US", result.country_code
  end

  def test_ip2location_lookup_loopback_address
    result = Geocoder.search("127.0.0.1").first
    assert_equal "INVALID IP ADDRESS", result.country_code
  end

  def test_ip2location_lookup_private_address
    result = Geocoder.search("172.19.0.1").first
    assert_equal "INVALID IP ADDRESS", result.country_code
  end

  def test_ip2location_extra_data
    Geocoder.configure(:ip2location => {:package => "WS3"})
    result = Geocoder.search("8.8.8.8").first
    assert_equal "United States", result.country_name
    assert_equal "California", result.region_name
    assert_equal "Mountain View", result.city_name
  end
end
