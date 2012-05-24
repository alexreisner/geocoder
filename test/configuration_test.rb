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

    Geocoder::Configuration.distances = :spherical
    angle = Geocoder::Calculations.bearing_between([50,-85], [40.750354, -73.993371]).round
    assert_equal     136, angle
    assert_not_equal 130, angle

    Geocoder::Configuration.distances = :linear
    angle = Geocoder::Calculations.bearing_between([50,-85], [40.750354, -73.993371]).round
    assert_not_equal 136, angle
    assert_equal     130, angle
  end

  # --- Geocoder#configure distances configuration ---
  def test_geocoder_configuration
    # DSL
    Geocoder.configure do |config|
      config.units  = :mi
      config.distances = :linear
    end

    assert_equal Geocoder::Configuration.units, :mi
    distance = Geocoder::Calculations.distance_between([0,0], [0,1]).round
    assert_not_equal 111, distance
    assert_equal      69, distance

    assert_equal Geocoder::Configuration.distances, :linear
    angle = Geocoder::Calculations.bearing_between([50,-85], [40.750354, -73.993371]).round
    assert_not_equal 136, angle
    assert_equal     130, angle

    # Direct
    Geocoder.configure.units  = :km
    Geocoder.configure.distances = :spherical

    assert_equal Geocoder::Configuration.units, :km
    distance = Geocoder::Calculations.distance_between([0,0], [0,1]).round
    assert_equal    111, distance
    assert_not_equal 69, distance

    assert_equal Geocoder::Configuration.distances, :spherical
    angle = Geocoder::Calculations.bearing_between([50,-85], [40.750354, -73.993371]).round
    assert_equal     136, angle
    assert_not_equal 130, angle
  end

  # Geocoder per-model configuration
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
    Geocoder.configure.units  = :km
    assert_equal 69, v.distance_to([0,1], :mi).round

    # per-model configuration > global configuration
    Landmark.reverse_geocoded_by :latitude, :longitude, :method => :spherical, :units => :mi
    assert_equal 69, v.distance_to([0,1]).round

    # method option > per-model configuration
    assert_equal 111, v.distance_to([0,1], :km).round
  end
end
