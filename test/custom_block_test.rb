# encoding: utf-8
require 'test_helper'

class CustomBlockTest < Test::Unit::TestCase

  def test_geocode_with_block_runs_block
    e = Event.new(*venue_params(:msg))
    coords = [40.750354, -73.993371]
    e.geocode
    assert_equal coords.map{ |c| c.to_s }.join(','), e.coords_string
  end

  def test_geocode_with_block_doesnt_auto_assign_coordinates
    e = Event.new(*venue_params(:msg))
    e.geocode
    assert_nil e.latitude
    assert_nil e.longitude
  end

  def test_reverse_geocode_with_block_runs_block
    e = Party.new(*landmark_params(:msg))
    e.reverse_geocode
    assert_equal "US", e.country
  end

  def test_reverse_geocode_with_block_doesnt_auto_assign_address
    e = Party.new(*landmark_params(:msg))
    e.reverse_geocode
    assert_nil e.address
  end
end

