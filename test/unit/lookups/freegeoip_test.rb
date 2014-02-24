# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class FreegeoipTest < GeocoderTestCase

  def setup
    Geocoder.configure(ip_lookup: :freegeoip)
  end

  def test_result_on_ip_address_search
    result = Geocoder.search("74.200.247.59").first
    assert result.is_a?(Geocoder::Result::Freegeoip)
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
