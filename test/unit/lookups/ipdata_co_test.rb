# encoding: utf-8
require 'test_helper'

class IpdataCoTest < GeocoderTestCase

  def setup
    Geocoder.configure(ip_lookup: :ipdata_co)
  end

  def test_result_on_ip_address_search
    result = Geocoder.search("74.200.247.59").first
    assert result.is_a?(Geocoder::Result::IpdataCo)
  end

  def test_invalid_json
    Geocoder.configure(:always_raise => [Geocoder::ResponseParseError])
    assert_raise Geocoder::ResponseParseError do
      Geocoder.search("8.8.8", ip_address: true)
    end
  end

  def test_result_components
    result = Geocoder.search("74.200.247.59").first
    assert_equal "Jersey City, NJ 07302, United States", result.address
  end

end
