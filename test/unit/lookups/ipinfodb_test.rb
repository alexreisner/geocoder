# encoding: utf-8
require 'test_helper'

class IpinfodbTest < GeocoderTestCase

  def setup
    Geocoder.configure(:ip_lookup => :ipinfodb, :api_key => 'IPINFODB_API_KEY')
  end

  def test_ipinfodb_lookup_address
    result = Geocoder.search("8.8.8.8").first
    assert_equal "US", result.countryCode
    assert_equal "United States", result.countryName
    assert_equal "California", result.regionName
    assert_equal "Mountain View", result.cityName
  end

  def test_ipinfodb_lookup_loopback_address
    result = Geocoder.search("127.0.0.1").first
    assert_equal "-", result.countryCode
  end
end
