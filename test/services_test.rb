# encoding: utf-8
require 'test_helper'

class ServicesTest < Test::Unit::TestCase

  # --- Google ---

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
    assert_match /bounds=40.0+%2C-120.0+%7C39.0+%2C-121.0+/, url
  end

  def test_google_query_url_contains_region
    lookup = Geocoder::Lookup::Google.new
    url = lookup.query_url(Geocoder::Query.new(
      "Some Intersection",
      :region => "gb"
    ))
    assert_match /region=gb/, url
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

  # --- Google Premier ---

  def test_google_premier_result_components
    Geocoder.configure(:lookup => :google_premier)
    set_api_key!(:google_premier)
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Manhattan",
      result.address_components_of_type(:sublocality).first['long_name']
  end

  def test_google_premier_query_url
    Geocoder.configure(:api_key => ["deadbeef", "gme-test", "test-dev"])
    assert_equal "http://maps.googleapis.com/maps/api/geocode/json?address=Madison+Square+Garden%2C+New+York%2C+NY&channel=test-dev&client=gme-test&language=en&sensor=false&signature=doJvJqX7YJzgV9rJ0DnVkTGZqTg=",
      Geocoder::Lookup::GooglePremier.new.query_url(Geocoder::Query.new("Madison Square Garden, New York, NY"))
  end


  # --- Yahoo ---

  def test_yahoo_no_results
    Geocoder.configure(:lookup => :yahoo)
    set_api_key!(:yahoo)
    assert_equal [], Geocoder.search("no results")
  end

  def test_yahoo_error
    Geocoder.configure(:lookup => :yahoo)
    set_api_key!(:yahoo)
    # keep test output clean: suppress timeout warning
    orig = $VERBOSE; $VERBOSE = nil
    assert_equal [], Geocoder.search("error")
  ensure
    $VERBOSE = orig
  end

  def test_yahoo_result_components
    Geocoder.configure(:lookup => :yahoo)
    set_api_key!(:yahoo)
    result = Geocoder.search("madison square garden").first
    assert_equal "10001", result.postal_code
  end

  def test_yahoo_address_formatting
    Geocoder.configure(:lookup => :yahoo)
    set_api_key!(:yahoo)
    result = Geocoder.search("madison square garden").first
    assert_equal "Madison Square Garden, New York, NY 10001, United States", result.address
  end

  def test_yahoo_raises_exception_when_over_query_limit
    Geocoder.configure(:always_raise => [Geocoder::OverQueryLimitError])
    l = Geocoder::Lookup.get(:yahoo)
    assert_raises Geocoder::OverQueryLimitError do
      l.send(:results, Geocoder::Query.new("over limit"))
    end
  end

  # --- Geocoder.ca ---

  def test_geocoder_ca_result_components
    Geocoder.configure(:lookup => :geocoder_ca)
    set_api_key!(:geocoder_ca)
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

  # --- MaxMind ---

  def test_maxmind_result_on_ip_address_search
    Geocoder.configure(:ip_lookup => :maxmind, :maxmind => {:service => :city_isp_org})
    result = Geocoder.search("74.200.247.59").first
    assert result.is_a?(Geocoder::Result::Maxmind)
  end

  def test_maxmind_result_knows_country_service_name
    Geocoder.configure(:ip_lookup => :maxmind, :maxmind => {:service => :country})
    assert_equal :country, Geocoder.search("24.24.24.21").first.service_name
  end

  def test_maxmind_result_knows_city_service_name
    Geocoder.configure(:ip_lookup => :maxmind, :maxmind => {:service => :city})
    assert_equal :city, Geocoder.search("24.24.24.22").first.service_name
  end

  def test_maxmind_result_knows_city_isp_org_service_name
    Geocoder.configure(:ip_lookup => :maxmind, :maxmind => {:service => :city_isp_org})
    assert_equal :city_isp_org, Geocoder.search("24.24.24.23").first.service_name
  end

  def test_maxmind_result_knows_omni_service_name
    Geocoder.configure(:ip_lookup => :maxmind, :maxmind => {:service => :omni})
    assert_equal :omni, Geocoder.search("24.24.24.24").first.service_name
  end

  def test_maxmind_special_result_components
    Geocoder.configure(:ip_lookup => :maxmind, :maxmind => {:service => :omni})
    result = Geocoder.search("24.24.24.24").first
    assert_equal "Road Runner", result.isp_name
    assert_equal "Cable/DSL", result.netspeed
    assert_equal "rr.com", result.domain
  end

  def test_maxmind_raises_exception_when_service_not_configured
    Geocoder.configure(:ip_lookup => :maxmind)
    Geocoder.configure(:maxmind => {:service => nil})
    assert_raises Geocoder::ConfigurationError do
      Geocoder::Query.new("24.24.24.24").url
    end
  end


  # --- Bing ---

  def test_bing_result_components
    Geocoder.configure(:lookup => :bing)
    set_api_key!(:bing)
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Madison Square Garden, NY", result.address
    assert_equal "NY", result.state
    assert_equal "New York", result.city
  end

  def test_bing_no_results
    Geocoder.configure(:lookup => :bing)
    set_api_key!(:bing)
    results = Geocoder.search("no results")
    assert_equal 0, results.length
  end

  # --- Nominatim ---

  def test_nominatim_result_components
    Geocoder.configure(:lookup => :nominatim)
    set_api_key!(:nominatim)
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "10001", result.postal_code
  end

  def test_nominatim_address_formatting
    Geocoder.configure(:lookup => :nominatim)
    set_api_key!(:nominatim)
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Madison Square Garden, West 31st Street, Long Island City, New York City, New York, 10001, United States of America",
      result.address
  end

  def test_nominatim_host_config
    Geocoder.configure(:lookup => :nominatim, :nominatim => {:host => "local.com"})
    lookup = Geocoder::Lookup::Nominatim.new
    query = Geocoder::Query.new("Bluffton, SC")
    assert_match %r(http://local\.com), lookup.query_url(query)
  end

  # --- MapQuest ---

  def test_api_route
    Geocoder.configure(:lookup => :mapquest, :api_key => "abc123")
    lookup = Geocoder::Lookup::Mapquest.new
    query = Geocoder::Query.new("Bluffton, SC")
    res = lookup.query_url(query)
    assert_equal "http://www.mapquestapi.com/geocoding/v1/address?key=abc123&location=Bluffton%2C+SC",
      res
  end

  def test_mapquest_result_components
    Geocoder.configure(:lookup => :mapquest)
    set_api_key!(:mapquest)
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "10001", result.postal_code
  end

  def test_mapquest_address_formatting
    Geocoder.configure(:lookup => :mapquest)
    set_api_key!(:mapquest)
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "46 West 31st Street, New York, NY, 10001, US",
      result.address
  end

  # --- Esri ---

  def test_esri_query_for_geocode
    query = Geocoder::Query.new("Bluffton, SC")
    lookup = Geocoder::Lookup.get(:esri)
    res = lookup.query_url(query)
    assert_equal "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/find?f=pjson&outFields=%2A&text=Bluffton%2C+SC",
      res
  end

  def test_esri_query_for_reverse_geocode
    query = Geocoder::Query.new([45.423733, -75.676333])
    lookup = Geocoder::Lookup.get(:esri)
    res = lookup.query_url(query)
    assert_equal "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?f=pjson&location=-75.676333%2C45.423733&outFields=%2A",
      res
  end

  def test_esri_results_component
    Geocoder.configure(:lookup => :esri)
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "10001", result.postal_code
    assert_equal "USA", result.country
    assert_equal "Madison Square Garden", result.address
    assert_equal "New York", result.city
    assert_equal "New York", result.state
    assert_equal 40.75004981300049, result.coordinates[0]
    assert_equal -73.99423889799965, result.coordinates[1]
  end
  
  def test_esri_results_component_when_reverse_geocoding
    Geocoder.configure(:lookup => :esri)
    result = Geocoder.search([45.423733, -75.676333]).first
    assert_equal "75007", result.postal_code
    assert_equal "FRA", result.country
    assert_equal "4 Avenue Gustave Eiffel", result.address
    assert_equal "Paris", result.city
    assert_equal "Île-de-France", result.state
    assert_equal 48.858129997357558, result.coordinates[0]
    assert_equal 2.2956200048981574, result.coordinates[1]
  end

end
