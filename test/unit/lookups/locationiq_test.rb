# encoding: utf-8
require 'unit/lookups/nominatim_test'
require 'test_helper'

class LocationIq < NominatimTest

  def setup
    Geocoder.configure(lookup: :locationiq)
    set_api_key!(:locationiq)
  end

  def test_url_contains_api_key
    Geocoder.configure(locationiq: {api_key: "abc123"})
    query = Geocoder::Query.new("Leadville, CO")
    assert_equal "http://locationiq.org/v1/search.php?key=abc123&accept-language=en&addressdetails=1&format=json&q=Leadville%2C+CO", query.url
  end

  def test_raises_exception_with_invalid_api_key
    Geocoder.configure(always_raise: [Geocoder::InvalidApiKey])
    assert_raises Geocoder::InvalidApiKey do
      Geocoder.search("invalid api key")
    end
  end
end
