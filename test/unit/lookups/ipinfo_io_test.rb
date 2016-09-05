# encoding: utf-8
require 'test_helper'

class IpinfoIoTest < GeocoderTestCase

  def test_ipinfo_io_use_http_without_token
    Geocoder.configure(:ip_lookup => :ipinfo_io, :use_https => true)
    query = Geocoder::Query.new("8.8.8.8")
    assert_match(/^http:/, query.url)
  end

  def test_ipinfo_io_uses_https_when_auth_token_set
    Geocoder.configure(:ip_lookup => :ipinfo_io, :api_key => "FOO_BAR_TOKEN", :use_https => true)
    query = Geocoder::Query.new("8.8.8.8")
    assert_match(/^https:/, query.url)
  end

  def test_ipinfo_io_lookup_loopback_address
    Geocoder.configure(:ip_lookup => :ipinfo_io, :use_https => true)
    result = Geocoder.search("127.0.0.1").first
    assert_equal 0.0, result.longitude
    assert_equal 0.0, result.latitude
    assert_equal "127.0.0.1", result.ip
  end

  def test_ipinfo_io_extra_attributes
    Geocoder.configure(:ip_lookup => :ipinfo_io, :use_https => true)
    result = Geocoder.search("8.8.8.8").first
    assert_equal "8.8.8.8", result.ip
    assert_equal "California", result.region
    assert_equal "94040", result.postal
  end
end
