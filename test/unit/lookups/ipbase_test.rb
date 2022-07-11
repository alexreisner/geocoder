# encoding: utf-8
require 'test_helper'

class IpbaseTest < GeocoderTestCase
  def setup
    super
    Geocoder.configure(ip_lookup: :ipbase, lookup: :ipbase)
  end

  def test_no_results
    results = Geocoder.search("no results")
    assert_equal 0, results.length
  end

  def test_no_data
    results = Geocoder.search("no data")
    assert_equal 0, results.length
  end

  def test_invalid_ip
    results = Geocoder.search("invalid ip")
    assert_equal 0, results.length
  end

  def test_result_on_ip_address_search
    result = Geocoder.search("74.200.247.59").first
    assert result.is_a?(Geocoder::Result::Ipbase)
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
    assert_equal "Jersey City, New Jersey 07302, United States", result.address
  end
end
