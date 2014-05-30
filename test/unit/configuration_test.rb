# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..")
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

  def test_with_valid_fallback_configuration
    Geocoder.configure(:lookup_fallback => {
        :to => :google,
        :on => 'foo'
    })

    assert Geocoder::Configuration.fallback_config_valid?
  end

  def test_with_empty_fallback_configuration
    Geocoder.configure(:lookup_fallback => {})

    refute Geocoder::Configuration.fallback_config_valid?
  end

  def test_with_invalid_fallback_configuration_missing_to
    Geocoder.configure(:lookup_fallback => {
        :on => 'foo'
    })

    refute Geocoder::Configuration.fallback_config_valid?
  end

  def test_with_invalid_fallback_configuration_missing_on
    Geocoder.configure(:lookup_fallback => {
        :to => :google
    })

    refute Geocoder::Configuration.fallback_config_valid?
  end
end
