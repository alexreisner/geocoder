# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class OkfTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :okf)
  end

  def test_okf_result_components
    result = Geocoder.search("Kirstinmäki 11b28").first
    assert_equal "Espoo",
      result.address_components_of_type(:administrative_area_level_3).first['long_name']
  end

  def test_okf_result_components_contains_route
    result = Geocoder.search("Kirstinmäki 11b28").first
    assert_equal "Kirstinmäki",
      result.address_components_of_type(:route).first['long_name']
  end

  def test_okf_result_components_contains_street_number
    result = Geocoder.search("Kirstinmäki 11b28").first
    assert_equal "1",
      result.address_components_of_type(:street_number).first['long_name']
  end

  def test_okf_street_address_returns_formatted_street_address
    result = Geocoder.search("Kirstinmäki 11b28").first
    assert_equal "Kirstinmäki 1", result.street_address
  end

  def test_okf_precision
    result = Geocoder.search("Kirstinmäki 11b28").first
    assert_equal "RANGE_INTERPOLATED", result.precision
  end
end
