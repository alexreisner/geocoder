# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..")
require 'test_helper'

class MethodAliasesTest < GeocoderTestCase

  def test_distance_from_is_alias_for_distance_to
    v = Place.new(*geocoded_object_params(:msg))
    v.latitude, v.longitude = [40.750354, -73.993371]
    assert_equal v.distance_from([30, -94]), v.distance_to([30, -94])
  end

  def test_fetch_coordinates_is_alias_for_geocode
    v = Place.new(*geocoded_object_params(:msg))
    coords = [40.750354, -73.993371]
    assert_equal coords, v.fetch_coordinates
    assert_equal coords, [v.latitude, v.longitude]
  end

  def test_fetch_address_is_alias_for_reverse_geocode
    v = PlaceReverseGeocoded.new(*reverse_geocoded_object_params(:msg))
    address = "4 Penn Plaza, New York, NY 10001, USA"
    assert_equal address, v.fetch_address
    assert_equal address, v.address
  end
end
