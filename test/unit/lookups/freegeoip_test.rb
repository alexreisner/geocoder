# encoding: utf-8
require 'test_helper'

class FreegeoipTest < GeocoderTestCase

  def setup
    Geocoder.configure(ip_lookup: :freegeoip)
  end

  def test_result_on_ip_address_search
    result = Geocoder.search("74.200.247.59").first
    assert result.is_a?(Geocoder::Result::Freegeoip)
  end

  def test_result_on_loopback_ip_address_search
    result = Geocoder.search("127.0.0.1").first
    assert_equal "127.0.0.1", result.ip
    assert_equal 'RD',        result.country_code
    assert_equal "Reserved",  result.country
  end

  def test_result_on_private_ip_address_search
    result = Geocoder.search("172.19.0.1").first
    assert_equal "172.19.0.1", result.ip
    assert_equal 'RD',         result.country_code
    assert_equal "Reserved",   result.country
  end

  def test_result_components
    result = Geocoder.search("74.200.247.59").first
    assert_equal "Plano, TX 75093, United States", result.address
  end

  def test_host_config
    Geocoder.configure(freegeoip: {host: "local.com"})
    lookup = Geocoder::Lookup::Freegeoip.new
    query = Geocoder::Query.new("24.24.24.23")
    assert_match %r(http://local\.com), lookup.query_url(query)
  end
end
