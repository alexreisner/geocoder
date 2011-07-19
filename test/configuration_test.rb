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

  # --- default configuration ---
  def test_default_units_in_kilometers
    assert_equal 111, Geocoder::Calculations.distance_between([0,0], [0,1]).round
  end

  # --- class method configuration ---
  def test_configurated_by_class_method
    Geocoder::Configuration.units = :mi
    distance = Geocoder::Calculations.distance_between([0,0], [0,1]).round
    assert_not_equal 111, distance
    assert_equal 69, distance

    Geocoder::Configuration.units = :km
    distance = Geocoder::Calculations.distance_between([0,0], [0,1]).round
    assert_equal 111, distance
    assert_not_equal 69, distance
  end

  # --- Geocoder#configure method configuration ---
  def test_geocoder_configuration
    Geocoder.configure { config.units = :mi }

    assert_equal Geocoder::Configuration.units, :mi
    distance = Geocoder::Calculations.distance_between([0,0], [0,1]).round
    assert_not_equal 111, distance
    assert_equal 69, distance

    Geocoder.configure.units = :km

    assert_equal Geocoder::Configuration.units, :km
    distance = Geocoder::Calculations.distance_between([0,0], [0,1]).round
    assert_equal 111, distance
    assert_not_equal 69, distance
  end
end

