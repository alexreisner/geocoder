# encoding: utf-8
require 'test_helper'

class BingTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :bing)
    set_api_key!(:bing)
  end

  def test_query_for_reverse_geocode
    lookup = Geocoder::Lookup::Bing.new
    url = lookup.query_url(Geocoder::Query.new([45.423733, -75.676333]))
    assert_match(/Locations\/45.423733/, url)
  end

  def test_result_components
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Madison Square Garden, NY", result.address
    assert_equal "NY", result.state
    assert_equal "New York", result.city
  end

  def test_result_viewport
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal [
      40.744944289326668,
      -74.002353921532631,
      40.755675807595253,
      -73.983625397086143
    ], result.viewport
  end

  def test_no_results
    results = Geocoder.search("no results")
    assert_equal 0, results.length
  end

  def test_query_url_contains_region
    lookup = Geocoder::Lookup::Bing.new
    url = lookup.query_url(Geocoder::Query.new(
      "manchester",
      :region => "uk"
    ))
    assert_match(/Locations\/uk\?q=manchester/, url)
    assert_no_match(/query/, url)
  end

  def test_query_url_without_region
    lookup = Geocoder::Lookup::Bing.new
    url = lookup.query_url(Geocoder::Query.new(
      "manchester"
    ))
    assert_match(/Locations\?q=manchester/, url)
    assert_no_match(/query/, url)
  end

  def test_query_url_contains_address_with_spaces
    lookup = Geocoder::Lookup::Bing.new
    url = lookup.query_url(Geocoder::Query.new(
      "manchester, lancashire",
      :region => "uk"
    ))
    assert_match(/Locations\/uk\?q=manchester,%20lancashire/, url)
    assert_no_match(/query/, url)
  end

  def test_query_url_contains_address_with_trailing_and_leading_spaces
    lookup = Geocoder::Lookup::Bing.new
    url = lookup.query_url(Geocoder::Query.new(
      " manchester, lancashire ",
      :region => "uk"
    ))
    assert_match(/Locations\/uk\?q=manchester,%20lancashire/, url)
    assert_no_match(/query/, url)
  end

  def test_raises_exception_when_service_unavailable
    Geocoder.configure(:always_raise => [Geocoder::ServiceUnavailable])
    l = Geocoder::Lookup.get(:bing)
    assert_raises Geocoder::ServiceUnavailable do
      l.send(:results, Geocoder::Query.new("service unavailable"))
    end
  end

  def test_raises_exception_when_bing_returns_forbidden_request
    Geocoder.configure(:always_raise => [Geocoder::RequestDenied])
    assert_raises Geocoder::RequestDenied do
      Geocoder.search("forbidden request")
    end
  end

  def test_raises_exception_when_bing_returns_internal_server_error
    Geocoder.configure(:always_raise => [Geocoder::ServiceUnavailable])
    assert_raises Geocoder::ServiceUnavailable do
      Geocoder.search("internal server error")
    end
  end
end
