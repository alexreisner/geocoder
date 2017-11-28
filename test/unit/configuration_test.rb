# encoding: utf-8
require 'test_helper'

class ConfigurationTest < GeocoderTestCase
  def setup
    Geocoder::Configuration.set_defaults
  end

  def test_exception_raised_on_bad_lookup_config
    Geocoder.configure(:lookup => :stoopid)
    assert_raises Geocoder::ConfigurationError do
      Geocoder.search "something dumb"
    end
  end

  def test_setting_with_class_method
    Geocoder::Configuration.units = :test
    assert_equal :test, Geocoder.config.units
  end

  def test_setting_with_configure_method
    Geocoder.configure(:units => :test)
    assert_equal :test, Geocoder.config.units
  end

  def test_config_for_lookup
    Geocoder.configure(
      :timeout => 5,
      :api_key => "aaa",
      :google => {
        :timeout => 2
      }
    )
    assert_equal 2, Geocoder.config_for_lookup(:google).timeout
    assert_equal "aaa", Geocoder.config_for_lookup(:google).api_key
  end

  def test_configuration_chain
    v = PlaceReverseGeocoded.new(*reverse_geocoded_object_params(:msg))
    v.latitude  = 0
    v.longitude = 0

    # method option > global configuration
    Geocoder.configure(:units => :km)
    assert_equal 69, v.distance_to([0,1], :mi).round

    # per-model configuration > global configuration
    PlaceReverseGeocoded.reverse_geocoded_by :latitude, :longitude, method: :spherical, units: :mi
    assert_equal 69, v.distance_to([0,1]).round

    # method option > per-model configuration
    assert_equal 111, v.distance_to([0,1], :km).round
  end

  def test_merge_into_lookup_config
    base = {
      timeout: 5,
      api_key: "xxx"
    }
    new = {
      timeout: 10,
      units: :km,
    }
    merged = {
      timeout: 10, # overwritten
      units: :km, # added
      api_key: "xxx" # preserved
    }
    Geocoder.configure(google: base)
    Geocoder.merge_into_lookup_config(:google, new)
    assert_equal merged, Geocoder.config[:google]
  end

  def test_enable_cache_compression
    # Lookups are static so we need to remove the cache before this test
    Geocoder::Lookup.get(:google).instance_variable_set(:@cache, nil)

    store = {}
    Geocoder.configure(:cache => store, :cache_compress => true, :lookup => :google)
    value = "a" * 1024

    Geocoder::Lookup.get(:google).cache["key"] = value

    assert_equal "geocoder/compressed;#{Zlib::Deflate.deflate(value)}", store["geocoder:key"]
  end

  def test_disable_cache_compression
    # Lookups are static so we need to remove the cache before this test
    Geocoder::Lookup.get(:google).instance_variable_set(:@cache, nil)

    store = {}
    Geocoder.configure(:cache => store, :cache_compress => false, :lookup => :google)
    value = "a" * 1024

    Geocoder::Lookup.get(:google).cache["key"] = value

    assert_equal value, store["geocoder:key"]
  end
end
