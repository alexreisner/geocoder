# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class TelizeTest < GeocoderTestCase

  def setup
    Geocoder.configure(ip_lookup: :telize)
  end

  def test_result_on_ip_address_search
    result = Geocoder.search("74.200.247.59").first
    assert result.is_a?(Geocoder::Result::Telize)
  end

  def test_result_components
    result = Geocoder.search("74.200.247.59").first
    assert_equal "Plano, TX 75093, United States", result.address
  end

  def test_no_results
    results = Geocoder.search("10.10.10.10")
    assert_equal 0, results.length
  end

  def test_invalid_address
    results = Geocoder.search("555.555.555.555")
    assert_equal 0, results.length
  end

  def test_uses_http_even_if_use_https_true
    Geocoder.configure(use_https: true)
    result = Geocoder.search("74.200.247.59").first
    assert result.is_a?(Geocoder::Result::Telize)
  end
end
