# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class GeocoderCaTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :geocoder_ca)
    set_api_key!(:geocoder_ca)
  end

  def test_result_components
    result = Geocoder.search([45.423733, -75.676333]).first
    assert_equal "CA", result.country_code
    assert_equal "289 Somerset ST E, Ottawa, ON K1N6W1, Canada", result.address
  end
end
