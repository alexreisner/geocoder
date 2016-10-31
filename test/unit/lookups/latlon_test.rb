# encoding: utf-8
require 'test_helper'

class LatlonTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :latlon)
    set_api_key!(:latlon)
  end

  def test_result_components
    result = Geocoder.search("6000 Universal Blvd, Orlando, FL 32819").first
    assert_equal "6000", result.number
    assert_equal "Universal", result.street_name
    assert_equal "Blvd", result.street_type
    assert_equal "Universal Blvd", result.street
    assert_equal "Orlando", result.city
    assert_equal "FL", result.state
    assert_equal "32819", result.zip
    assert_equal "6000 Universal Blvd, Orlando, FL 32819", result.formatted_address
    assert_equal(28.4750507575094, result.latitude)
    assert_equal(-81.4630386931719, result.longitude)
  end

  def test_no_results
    results = Geocoder.search("no results")
    assert_equal 0, results.length
  end

  def test_latlon_reverse_url
    query = Geocoder::Query.new([45.423733, -75.676333])
    assert_match(/reverse_geocode/, query.url)
  end

  def test_raises_api_key_exception
    Geocoder.configure Geocoder.configure(:always_raise => [Geocoder::InvalidApiKey])
    assert_raises Geocoder::InvalidApiKey do
      Geocoder.search("invalid key")
    end
  end

end
