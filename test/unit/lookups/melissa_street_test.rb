# encoding: utf-8
require 'test_helper'

class MelissaStreetTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(lookup: :melissa_street)
    set_api_key!(:melissa_street)
  end

  def test_result_components
    result = Geocoder.search("1 Frank H Ogawa Plz Fl 3").first
    assert_equal "1", result.number
    assert_equal "1 Frank H Ogawa Plz Fl 3", result.street_address
    assert_equal "Plz", result.suffix
    assert_equal "CA", result.state
    assert_equal "94612-1932", result.postal_code
    assert_equal "Oakland", result.city
    assert_equal "US", result.country_code
    assert_equal "United States of America", result.country
    assert_equal([37.805402, -122.272797], result.coordinates)
  end

  def test_low_accuracy
    result = Geocoder.search("low accuracy").first
    assert_equal "United States of America", result.country
  end

  def test_raises_api_key_exception
    Geocoder.configure(:always_raise => [Geocoder::InvalidApiKey])
    assert_raises Geocoder::InvalidApiKey do
      Geocoder.search("invalid key")
    end
  end
end
