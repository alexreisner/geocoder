# encoding: utf-8
require 'test_helper'

class IpinfoIoTest < GeocoderTestCase
  def test_ipinfo_io_lookup_loopback_address
    Geocoder.configure(:ip_lookup => :ipinfo_io)
    result = Geocoder.search("127.0.0.1").first
    assert_nil result.latitude
    assert_nil result.longitude
    assert_equal "127.0.0.1", result.ip
  end

  def test_ipinfo_io_lookup_private_address
    Geocoder.configure(:ip_lookup => :ipinfo_io)
    result = Geocoder.search("172.19.0.1").first
    assert_nil result.latitude
    assert_nil result.longitude
    assert_equal "172.19.0.1", result.ip
  end

  def test_ipinfo_io_extra_attributes
    Geocoder.configure(:ip_lookup => :ipinfo_io, :use_https => true)
    result = Geocoder.search("8.8.8.8").first
    assert_equal "8.8.8.8", result.ip
    assert_equal "California", result.region
    assert_equal "94040", result.postal
  end
end
