# encoding: utf-8
require 'test_helper'

class IpregistryTest < GeocoderTestCase
  def test_lookup_loopback_address
    Geocoder.configure(:ip_lookup => :ipregistry)
    result = Geocoder.search("127.0.0.1").first
    assert_nil result.latitude
    assert_nil result.longitude
    assert_equal "127.0.0.1", result.ip
  end

  def test_lookup_private_address
    Geocoder.configure(:ip_lookup => :ipregistry)
    result = Geocoder.search("172.19.0.1").first
    assert_nil result.latitude
    assert_nil result.longitude
    assert_equal "172.19.0.1", result.ip
  end

  def test_known_ip_address
    Geocoder.configure(:ip_lookup => :ipregistry)
    result = Geocoder.search("8.8.8.8").first
    assert_equal "8.8.8.8", result.ip
    assert_equal "California", result.state
    assert_equal "USD", result.currency_code
    assert_equal "NA", result.location_continent_code
    assert_equal "US", result.location_country_code
    assert_equal false, result.security_is_tor
    assert_equal "America/Los_Angeles", result.time_zone_id
  end
end
