# encoding: utf-8
require 'mongoid_test_helper'

class MongoidTest < Test::Unit::TestCase
  def test_geocoded_check
    p = Place.new(*venue_params(:msg))
    p.location = [40.750354, -73.993371]
    assert p.geocoded?
  end

  def test_distance_to_returns_float
    p = Place.new(*venue_params(:msg))
    p.location = [40.750354, -73.993371]
    assert p.distance_to([30, -94]).is_a?(Float)
  end

  def test_custom_coordinate_field_near_scope
    location = [40.750354, -73.993371]
    p = Place.near(location)
    key = Mongoid::VERSION >= "3" ? "location" : :location
    assert_equal p.selector[key]['$nearSphere'], location.reverse
  end

  def test_model_configuration
    p = Place.new(*venue_params(:msg))
    p.location = [0, 0]

    Place.geocoded_by :address, :coordinates => :location, :units => :km
    assert_equal 111, p.distance_to([0,1]).round

    Place.geocoded_by :address, :coordinates => :location, :units => :mi
    assert_equal 69, p.distance_to([0,1]).round
  end

  def test_index_is_skipped_if_skip_option_flag
    result = PlaceWithoutIndex.index_options.keys.flatten[0] == :coordinates
    assert !result
  end
end
