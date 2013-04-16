# encoding: utf-8
require 'test_helper'

class LookupTest < Test::Unit::TestCase

  def test_responds_to_name_method
    Geocoder::Lookup.all_services.each do |l|
      lookup = Geocoder::Lookup.get(l)
      assert lookup.respond_to?(:name),
        "Lookup #{l} does not respond to #name method."
    end
  end

  def test_search_returns_empty_array_when_no_results
    Geocoder::Lookup.all_services_except_test.each do |l|
      lookup = Geocoder::Lookup.get(l)
      set_api_key!(l)
      assert_equal [], lookup.send(:results, Geocoder::Query.new("no results")),
        "Lookup #{l} does not return empty array when no results."
    end
  end

  def test_query_url_contains_values_in_params_hash
    Geocoder::Lookup.all_services_except_test.each do |l|
      next if l == :freegeoip # does not use query string
      set_api_key!(l)
      url = Geocoder::Lookup.get(l).query_url(Geocoder::Query.new(
        "test", :params => {:one_in_the_hand => "two in the bush"}
      ))
      # should be "+"s for all lookups except Yahoo
      assert_match /one_in_the_hand=two(%20|\+)in(%20|\+)the(%20|\+)bush/, url,
        "Lookup #{l} does not appear to support arbitrary params in URL"
    end
  end

  {
    :esri => :l,
    :bing => :key,
    :geocoder_ca => :auth,
    :google => :language,
    :google_premier => :language,
    :mapquest => :key,
    :maxmind => :l,
    :nominatim => :"accept-language",
    :yahoo => :locale,
    :yandex => :plng
  }.each do |l,p|
    define_method "test_passing_param_to_#{l}_query_overrides_configuration_value" do
      set_api_key!(l)
      url = Geocoder::Lookup.get(l).query_url(Geocoder::Query.new(
        "test", :params => {p => "xxxx"}
      ))
      assert_match /#{p}=xxxx/, url,
        "Param passed to #{l} lookup does not override configuration value"
    end
  end

  def test_raises_exception_on_invalid_key
    Geocoder.configure(:always_raise => [Geocoder::InvalidApiKey])
    #Geocoder::Lookup.all_services_except_test.each do |l|
    [:bing, :yahoo, :yandex, :maxmind].each do |l|
      lookup = Geocoder::Lookup.get(l)
      assert_raises Geocoder::InvalidApiKey do
        lookup.send(:results, Geocoder::Query.new("invalid key"))
      end
    end
  end

  def test_returns_empty_array_on_invalid_key
    # keep test output clean: suppress timeout warning
    orig = $VERBOSE; $VERBOSE = nil
    #Geocoder::Lookup.all_services_except_test.each do |l|
    [:bing, :yahoo, :yandex, :maxmind].each do |l|
      Geocoder.configure(:lookup => l)
      set_api_key!(l)
      assert_equal [], Geocoder.search("invalid key")
    end
  ensure
    $VERBOSE = orig
  end

  def test_does_not_choke_on_nil_address
    Geocoder::Lookup.all_services.each do |l|
      Geocoder.configure(:lookup => l)
      assert_nothing_raised { Venue.new("Venue", nil).geocode }
    end
  end

  def test_hash_to_query
    g = Geocoder::Lookup::Google.new
    assert_equal "a=1&b=2", g.send(:hash_to_query, {:a => 1, :b => 2})
  end

  def test_google_api_key
    Geocoder.configure(:api_key => "MY_KEY")
    g = Geocoder::Lookup::Google.new
    assert_match "key=MY_KEY", g.query_url(Geocoder::Query.new("Madison Square Garden, New York, NY  10001, United States"))
  end

  def test_geocoder_ca_showpostal
    Geocoder.configure(:api_key => "MY_KEY")
    g = Geocoder::Lookup::GeocoderCa.new
    assert_match "showpostal=1", g.query_url(Geocoder::Query.new("Madison Square Garden, New York, NY  10001, United States"))
  end

  def test_raises_configuration_error_on_missing_key
    assert_raises Geocoder::ConfigurationError do
      Geocoder.configure(:lookup => :bing, :api_key => nil)
      Geocoder.search("Madison Square Garden, New York, NY  10001, United States")
    end
  end

  def test_handle
    assert_equal :google, Geocoder::Lookup::Google.new.handle
    assert_equal :geocoder_ca, Geocoder::Lookup::GeocoderCa.new.handle
  end
end
