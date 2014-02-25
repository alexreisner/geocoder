# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class GoogleTest < GeocoderTestCase

  def test_google_result_components
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Manhattan",
      result.address_components_of_type(:sublocality).first['long_name']
  end

  def test_google_result_components_contains_route
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Penn Plaza",
      result.address_components_of_type(:route).first['long_name']
  end

  def test_google_result_components_contains_street_number
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "4",
      result.address_components_of_type(:street_number).first['long_name']
  end

  def test_google_returns_city_when_no_locality_in_result
    result = Geocoder.search("no locality").first
    assert_equal "Haram", result.city
  end

  def test_google_city_results_returns_nil_if_no_matching_component_types
    result = Geocoder.search("no city data").first
    assert_equal nil, result.city
  end

  def test_google_street_address_returns_formatted_street_address
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "4 Penn Plaza", result.street_address
  end

  def test_google_precision
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "ROOFTOP",
      result.precision
  end

  def test_google_query_url_contains_bounds
    lookup = Geocoder::Lookup::Google.new
    url = lookup.query_url(Geocoder::Query.new(
      "Some Intersection",
      :bounds => [[40.0, -120.0], [39.0, -121.0]]
    ))
    assert_match(/bounds=40.0+%2C-120.0+%7C39.0+%2C-121.0+/, url)
  end

  def test_google_query_url_contains_region
    lookup = Geocoder::Lookup::Google.new
    url = lookup.query_url(Geocoder::Query.new(
      "Some Intersection",
      :region => "gb"
    ))
    assert_match(/region=gb/, url)
  end

  def test_google_query_url_contains_components_when_given_as_string
    lookup = Geocoder::Lookup::Google.new
    url = lookup.query_url(Geocoder::Query.new(
      "Some Intersection",
      :components => "locality:ES"
    ))
    formatted = "components=" + CGI.escape("locality:ES")
    assert url.include?(formatted), "Expected #{formatted} to be included in #{url}"
  end

  def test_google_query_url_contains_components_when_given_as_array
    lookup = Geocoder::Lookup::Google.new
    url = lookup.query_url(Geocoder::Query.new(
      "Some Intersection",
      :components => ["country:ES", "locality:ES"]
    ))
    formatted = "components=" + CGI.escape("country:ES|locality:ES")
    assert url.include?(formatted), "Expected #{formatted} to be included in #{url}"
  end

end
