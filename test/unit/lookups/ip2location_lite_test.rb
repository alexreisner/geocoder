# encoding: utf-8
require 'test_helper'

class Ip2locationLiteTest < GeocoderTestCase
  def setup
    Geocoder.configure(ip_lookup: :ip2location_lite, ip2location_lite: { file: File.join('folder', 'test_file') })
  end

  def test_loopback
    result = Geocoder.search('127.0.0.1').first
    assert_equal '', result.country_short
  end
end