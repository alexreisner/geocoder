# encoding: utf-8
require 'test_helper'

class ConfigurationTest < Test::Unit::TestCase
  def setup
    Geocoder::Configuration.set_defaults
  end

  def test_exception_raised_on_bad_lookup_config
    Geocoder::Configuration.lookup = :stoopid
    assert_raises Geocoder::ConfigurationError do
      Geocoder.search "something dumb"
    end
  end

  # --- class method configuration ---
  def test_configurated_by_class_method
    Geocoder::Configuration.units = :mi
    distance = Geocoder::Calculations.distance_between([0,0], [0,1]).round
    assert_not_equal 111, distance
    assert_equal      69, distance

    Geocoder::Configuration.units = :km
    distance = Geocoder::Calculations.distance_between([0,0], [0,1]).round
    assert_equal    111, distance
    assert_not_equal 69, distance

    Geocoder::Configuration.method = :spherical
    angle = Geocoder::Calculations.bearing_between([50,-85], [40.750354, -73.993371]).round
    assert_equal     136, angle
    assert_not_equal 130, angle

    Geocoder::Configuration.method = :linear
    angle = Geocoder::Calculations.bearing_between([50,-85], [40.750354, -73.993371]).round
    assert_not_equal 136, angle
    assert_equal     130, angle
  end

  # --- Geocoder#configure method configuration ---
  def test_geocoder_configuration
    # DSL
    Geocoder.configure do
      config.units  = :mi
      config.method = :linear
    end

    assert_equal Geocoder::Configuration.units, :mi
    distance = Geocoder::Calculations.distance_between([0,0], [0,1]).round
    assert_not_equal 111, distance
    assert_equal      69, distance

    assert_equal Geocoder::Configuration.method, :linear
    angle = Geocoder::Calculations.bearing_between([50,-85], [40.750354, -73.993371]).round
    assert_not_equal 136, angle
    assert_equal     130, angle

    # Direct
    Geocoder.configure.units  = :km
    Geocoder.configure.method = :spherical

    assert_equal Geocoder::Configuration.units, :km
    distance = Geocoder::Calculations.distance_between([0,0], [0,1]).round
    assert_equal    111, distance
    assert_not_equal 69, distance

    assert_equal Geocoder::Configuration.method, :spherical
    angle = Geocoder::Calculations.bearing_between([50,-85], [40.750354, -73.993371]).round
    assert_equal     136, angle
    assert_not_equal 130, angle
  end

  # Geocoder per-model configuration
  def test_model_configuration
    Landmark.reverse_geocoded_by :latitude, :longitude, :method => :spherical, :units => :km
    assert_equal Landmark.geocoder_options[:units], :km
    assert_equal :spherical, Landmark.geocoder_options[:method]

    venue = Landmark.new(*landmark_params(:msg))
    venue.latitude  = 0
    venue.longitude = 0
    assert_equal 111, venue.distance_to([0,1]).round
    venue.latitude  = 40.750354
    venue.longitude = -73.993371
    assert_equal 136, venue.bearing_from([50,-85]).round
  end
end

