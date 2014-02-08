# encoding: utf-8
require 'test_helper'

class GeocodioTest < Test::Unit::TestCase

  def setup
    Geocoder.configure(lookup: :geocodio)
    set_api_key!(:geocodio)
  end

  def test_result_components
    result = Geocoder.search("1101 Pennsylvania Ave NW, Washington DC").first
    assert_equal 1.0, result.accuracy
    assert_equal "1101", result.number
    assert_equal "Ave", result.suffix
    assert_equal "DC", result.state
    assert_equal "20004", result.zip
    assert_equal "NW", result.postdirectional
    assert_equal "Washington", result.city
    assert_equal "1101 Pennsylvania Ave NW, Washington DC, 20004", result.formatted_address
    assert_equal({ "lat" => 38.895019, "lng" => -77.028095 }, result.location)
  end

  def test_no_results
    results = Geocoder.search("no results")
    assert_equal 0, results.length
  end
end
