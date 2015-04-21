# encoding: utf-8
require 'test_helper'

class PointpinTest < GeocoderTestCase

  def setup
    Geocoder.configure(ip_lookup: :pointpin, api_key: "abc123")
  end

  def test_result_on_ip_address_search
    result = Geocoder.search("80.111.55.55").first
    assert result.is_a?(Geocoder::Result::Pointpin)
  end

  def test_result_components
    result = Geocoder.search("80.111.55.55").first
    assert_equal "Dublin, Dublin City, 8, Ireland", result.address
  end

  def test_no_results
    silence_warnings do
      results = Geocoder.search("10.10.10.10")
      assert_equal 0, results.length
    end
  end

  def test_invalid_address
    silence_warnings do
      results = Geocoder.search("555.555.555.555", ip_address: true)
      assert_equal 0, results.length
    end
  end
end
