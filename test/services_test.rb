# encoding: utf-8
require 'test_helper'

class ServicesTest < Test::Unit::TestCase


  def test_query_url_contains_values_in_params_hash
    Geocoder::Lookup.all_services_except_test.each do |l|
      next if l == :freegeoip # does not use query string
      set_api_key!(l)
      url = Geocoder::Lookup.get(l).send(:query_url, Geocoder::Query.new(
        "test", :params => {:one_in_the_hand => "two in the bush"}
      ))
      # should be "+"s for all lookups except Yahoo
      assert_match /one_in_the_hand=two(%20|\+)in(%20|\+)the(%20|\+)bush/, url,
        "Lookup #{l} does not appear to support arbitrary params in URL"
    end
  end

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

  def test_google_query_url_contains_bounds
    lookup = Geocoder::Lookup::Google.new
    url = lookup.send(:query_url, Geocoder::Query.new(
      "Some Intersection",
      :bounds => [[40.0, -120.0], [39.0, -121.0]]
    ))
    assert_match /bounds=40.0+%2C-120.0+%7C39.0+%2C-121.0+/, url
  end

  # --- Google Premier ---

  def test_google_premier_result_components
    Geocoder::Configuration.lookup = :google_premier
    set_api_key!(:google_premier)
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Manhattan",
      result.address_components_of_type(:sublocality).first['long_name']
  end

  def test_google_premier_query_url
    Geocoder::Configuration.api_key = ["deadbeef", "gme-test", "test-dev"]
    assert_equal "http://maps.googleapis.com/maps/api/geocode/json?address=Madison+Square+Garden%2C+New+York%2C+NY&channel=test-dev&client=gme-test&language=en&sensor=false&signature=doJvJqX7YJzgV9rJ0DnVkTGZqTg=",
      Geocoder::Lookup::GooglePremier.new.send(:query_url, Geocoder::Query.new("Madison Square Garden, New York, NY"))
  end


  # --- Yahoo ---

  def test_yahoo_no_results
    Geocoder::Configuration.lookup = :yahoo
    assert_equal [], Geocoder.search("no results")
  end

  def test_yahoo_error
    Geocoder::Configuration.lookup = :yahoo
    # keep test output clean: suppress timeout warning
    orig = $VERBOSE; $VERBOSE = nil
    assert_equal [], Geocoder.search("error")
  ensure
    $VERBOSE = orig
  end

  def test_yahoo_result_components
    Geocoder::Configuration.lookup = :yahoo
    result = Geocoder.search("madison square garden").first
    assert_equal "10001", result.postal_code
  end

  def test_yahoo_address_formatting
    Geocoder::Configuration.lookup = :yahoo
    result = Geocoder.search("madison square garden").first
    assert_equal "Madison Square Garden, New York, NY 10001, United States", result.address
  end


  # --- Yandex ---

  def test_yandex_with_invalid_key
    # keep test output clean: suppress timeout warning
    orig = $VERBOSE; $VERBOSE = nil
    Geocoder::Configuration.lookup = :yandex
    assert_equal [], Geocoder.search("invalid key")
  ensure
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
  # --- MapQuest ---

  def test_api_route
    Geocoder::Configuration.lookup = :mapquest
    Geocoder::Configuration.api_key = "abc123"

    lookup = Geocoder::Lookup::Mapquest.new
    query = Geocoder::Query.new("Bluffton, SC")
    res = lookup.send(:query_url, query)
    assert_equal "http://www.mapquestapi.com/geocoding/v1/address?key=abc123&location=Bluffton%2C+SC",
      res
  end

  def test_mapquest_result_components
    Geocoder::Configuration.lookup = :mapquest
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "10001", result.postal_code
  end

  def test_mapquest_address_formatting
    Geocoder::Configuration.lookup = :mapquest
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "46 West 31st Street, New York, NY, 10001, US",
      result.address
  end
end
