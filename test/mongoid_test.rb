# encoding: utf-8
require 'test_helper'

begin
require 'mongoid'
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
end

rescue LoadError => crash
  warn 'Mongoid not installed, not tested.'
end
