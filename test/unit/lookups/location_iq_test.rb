# encoding: utf-8
require 'unit/lookups/nominatim_test'
require 'test_helper'

class LocationIq < NominatimTest

  def setup
    Geocoder.configure(lookup: :location_iq)
    set_api_key!(:location_iq)
  end

  def test_url_contains_api_key
    Geocoder.configure(location_iq: {api_key: "abc123"})
    query = Geocoder::Query.new("Leadville, CO")
    assert_equal "http://locationiq.org/v1/search.php?key=abc123&accept-language=en&addressdetails=1&format=json&q=Leadville%2C+CO", query.url
  end

  def test_raises_exception_with_invalid_api_key
    Geocoder.configure(always_raise: [Geocoder::InvalidApiKey])
    assert_raises Geocoder::InvalidApiKey do
      Geocoder.search("invalid api key")
    end
  end

  def test_raises_exception_with_request_denied
    Geocoder.configure(always_raise: [Geocoder::RequestDenied])
    assert_raises Geocoder::RequestDenied do
      Geocoder.search("request denied")
    end
  end

  def test_raises_exception_with_rate_limited
    Geocoder.configure(always_raise: [Geocoder::OverQueryLimitError])
    assert_raises Geocoder::OverQueryLimitError do
      Geocoder.search("over limit")
    end
  end

  def test_raises_exception_with_invalid_request
    Geocoder.configure(always_raise: [Geocoder::InvalidRequest])
    assert_raises Geocoder::InvalidRequest do
      Geocoder.search("invalid request")
    end
  end
end
