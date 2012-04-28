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
    assert_equal p.selector[:location]['$nearSphere'], location.reverse
  end

  def test_index_is_skipped_if_skip_option_flag
    result = PlaceWithoutIndex.index_options.keys.flatten[0] == :coordinates
    assert_equal result, false
  end
end
