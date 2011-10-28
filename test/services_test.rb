# encoding: utf-8
require 'test_helper'

class ServicesTest < Test::Unit::TestCase


  # --- Google ---

  def test_google_result_components
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Manhattan",
      result.address_components_of_type(:sublocality).first['long_name']
  end

  def test_google_returns_city_when_no_locality_in_result
    result = Geocoder.search("no locality").first
    assert_equal "Haram", result.city
  end

  def test_google_city_results_returns_nil_if_no_matching_component_types
    result = Geocoder.search("no city data").first
    assert_equal nil, result.city
  end

  def test_google_precision
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "ROOFTOP",
      result.precision
  end


  # --- Google Premier ---

  def test_google_premier_result_components
    Geocoder::Configuration.lookup = :google_premier
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Manhattan",
      result.address_components_of_type(:sublocality).first['long_name']
  end

  def test_google_premier_query_url
    Geocoder::Configuration.api_key = ["deadbeef", "gme-test", "test-dev"]
    assert_equal "http://maps.googleapis.com/maps/api/geocode/json?address=Madison+Square+Garden%2C+New+York%2C+NY&channel=test-dev&client=gme-test&language=en&sensor=false&signature=doJvJqX7YJzgV9rJ0DnVkTGZqTg=",
      Geocoder::Lookup::GooglePremier.new.send(:query_url, "Madison Square Garden, New York, NY", false)
  end


  # --- Yahoo ---

  def test_yahoo_result_components
    Geocoder::Configuration.lookup = :yahoo
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "10001", result.postal_code
  end

  def test_yahoo_address_formatting
    Geocoder::Configuration.lookup = :yahoo
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Madison Square Garden, New York, NY  10001, United States",
      result.address
  end


  # --- Yandex ---

  def test_yandex_with_invalid_key
    # keep test output clean: suppress timeout warning
    orig = $VERBOSE; $VERBOSE = nil
    Geocoder::Configuration.lookup = :yandex
    assert_equal [], Geocoder.search("invalid key")
    $VERBOSE = orig
  end


  # --- Geocoder.ca ---

  def test_geocoder_ca_result_components
    Geocoder::Configuration.lookup = :geocoder_ca
    result = Geocoder.search([45.423733, -75.676333]).first
    assert_equal "CA", result.country_code
    assert_equal "289 Somerset ST E, Ottawa, ON K1N6W1, Canada", result.address
  end


  # --- FreeGeoIp ---

  def test_freegeoip_result_on_ip_address_search
    result = Geocoder.search("74.200.247.59").first
    assert result.is_a?(Geocoder::Result::Freegeoip)
  end

  def test_freegeoip_result_components
    result = Geocoder.search("74.200.247.59").first
    assert_equal "Plano, TX 75093, United States", result.address
  end


  # --- Bing ---

  def test_bing_result_components
    Geocoder::Configuration.lookup = :bing
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Madison Square Garden, NY", result.address
    assert_equal "NY", result.state
    assert_equal "New York", result.city
  end

  def test_bing_no_results
    Geocoder::Configuration.lookup = :bing
    results = Geocoder.search("no results")
    assert_equal 0, results.length
  end

  # --- Nominatim ---

   def test_nominatim_result_components
    Geocoder::Configuration.lookup = :nominatim
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "10001", result.postal_code
  end

  def test_nominatim_address_formatting
    Geocoder::Configuration.lookup = :nominatim
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Madison Square Garden, West 31st Street, Long Island City, New York City, New York, 10001, United States of America",
      result.address
  end
end
