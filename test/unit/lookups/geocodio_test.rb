# encoding: utf-8
require 'test_helper'

class GeocodioTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :geocodio)
    set_api_key!(:geocodio)
  end

  def test_result_components
    result = Geocoder.search("1101 Pennsylvania Ave NW, Washington DC").first
    assert_equal 1.0, result.accuracy
    assert_equal "1101", result.number
    assert_equal "1101 Pennsylvania Ave NW", result.street_address
    assert_equal "Ave", result.suffix
    assert_equal "DC", result.state
    assert_equal "20004", result.zip
    assert_equal "NW", result.postdirectional
    assert_equal "Washington", result.city
    assert_equal "US", result.country_code
    assert_equal "United States", result.country
    assert_equal "1101 Pennsylvania Ave NW, Washington, DC 20004", result.formatted_address
    assert_equal({ "lat" => 38.895156, "lng" => -77.027405 }, result.location)
  end

  def test_reverse_canada_result
    result = Geocoder.search([43.652961, -79.382624]).first
    assert_equal 1.0, result.accuracy
    assert_equal "483", result.number
    assert_equal "Bay", result.street
    assert_equal "St", result.suffix
    assert_equal "ON", result.state
    assert_equal "Toronto", result.city
    assert_equal "CA", result.country_code
    assert_equal "Canada", result.country
  end

  def test_no_results
    results = Geocoder.search("no results")
    assert_equal 0, results.length
  end

  def test_geocodio_reverse_url
    query = Geocoder::Query.new([45.423733, -75.676333])
    assert_match(/reverse/, query.url)
  end

  def test_raises_invalid_request_exception
    Geocoder.configure Geocoder.configure(:always_raise => [Geocoder::InvalidRequest])
    assert_raises Geocoder::InvalidRequest do
      Geocoder.search("invalid")
    end
  end

  def test_raises_api_key_exception
    Geocoder.configure Geocoder.configure(:always_raise => [Geocoder::InvalidApiKey])
    assert_raises Geocoder::InvalidApiKey do
      Geocoder.search("bad api key")
    end
  end

  def test_raises_over_limit_exception
    Geocoder.configure Geocoder.configure(:always_raise => [Geocoder::OverQueryLimitError])
    assert_raises Geocoder::OverQueryLimitError do
      Geocoder.search("over query limit")
    end
  end
end
