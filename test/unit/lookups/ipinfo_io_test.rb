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
end
