# encoding: utf-8
require 'test_helper'

class ConfigurationTest < Test::Unit::TestCase
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

  def test_setting_with_block_syntax
    orig = $VERBOSE; $VERBOSE = nil
    Geocoder.configure do |config|
      config.units = :test
    end
    assert_equal :test, Geocoder.config.units
  ensure
    $VERBOSE = orig
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

  def test_model_configuration
    Landmark.reverse_geocoded_by :latitude, :longitude, :method => :spherical, :units => :km
    assert_equal :km,        Landmark.geocoder_options[:units]
    assert_equal :spherical, Landmark.geocoder_options[:method]

    v = Landmark.new(*landmark_params(:msg))
    v.latitude  = 0
    v.longitude = 0
    assert_equal 111, v.distance_to([0,1]).round
    v.latitude  = 40.750354
    v.longitude = -73.993371
    assert_equal 136, v.bearing_from([50,-85]).round
  end

  def test_configuration_chain
    v = Landmark.new(*landmark_params(:msg))
    v.latitude  = 0
    v.longitude = 0

    # method option > global configuration
    Geocoder.configure(:units => :km)
    assert_equal 69, v.distance_to([0,1], :mi).round

    # per-model configuration > global configuration
    Landmark.reverse_geocoded_by :latitude, :longitude, :method => :spherical, :units => :mi
    assert_equal 69, v.distance_to([0,1]).round

    # method option > per-model configuration
    assert_equal 111, v.distance_to([0,1], :km).round
  end
end
