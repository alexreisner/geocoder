# encoding: utf-8
require 'test_helper'

class GeocoderTest < GeocoderTestCase

  def test_distance_to_returns_float
    v = Place.new(*geocoded_object_params(:msg))
    v.latitude, v.longitude = [40.750354, -73.993371]
    assert (v.distance_to([30, -94])).is_a?(Float)
  end

  def test_coordinates_method_returns_array
    assert Geocoder.coordinates("Madison Square Garden, New York, NY").is_a?(Array)
  end

  def test_address_method_returns_string
    assert Geocoder.address([40.750354, -73.993371]).is_a?(String)
  end

  def test_geographic_center_doesnt_overwrite_argument_value
    # test for the presence of a bug that was introduced in version 0.9.11
    orig_points = [[52,8], [46,9], [42,5]]
    points = orig_points.clone
    Geocoder::Calculations.geographic_center(points)
    assert_equal orig_points, points
  end

  def test_geocode_assigns_and_returns_coordinates
    v = Place.new(*geocoded_object_params(:msg))
    coords = [40.750354, -73.993371]
    assert_equal coords, v.geocode
    assert_equal coords, [v.latitude, v.longitude]
  end

  def test_geocode_block_executed_when_no_results
    v = PlaceWithCustomResultsHandling.new("Nowhere", "no results")
    v.geocode
    assert_equal "NOT FOUND", v.coords_string
  end

  def test_reverse_geocode_assigns_and_returns_address
    v = PlaceReverseGeocoded.new(*reverse_geocoded_object_params(:msg))
    address = "4 Penn Plaza, New York, NY 10001, USA"
    assert_equal address, v.reverse_geocode
    assert_equal address, v.address
  end

  def test_forward_and_reverse_geocoding_on_same_model_works
    g = PlaceWithForwardAndReverseGeocoding.new("Exxon")
    g.address = "404 New St, Middletown, CT"
    g.geocode
    assert_not_nil g.lat
    assert_not_nil g.lon

    assert_nil g.location
    g.reverse_geocode
    assert_not_nil g.location
  end

  def test_geocode_with_custom_lookup_param
    v = PlaceWithCustomLookup.new(*geocoded_object_params(:msg))
    v.geocode
    assert_equal "Geocoder::Result::Nominatim", v.result_class.to_s
  end

  def test_geocode_with_custom_lookup_proc_param
    v = PlaceWithCustomLookupProc.new(*geocoded_object_params(:msg))
    v.geocode
    assert_equal "Geocoder::Result::Nominatim", v.result_class.to_s
  end

  def test_reverse_geocode_with_custom_lookup_param
    v = PlaceReverseGeocodedWithCustomLookup.new(*reverse_geocoded_object_params(:msg))
    v.reverse_geocode
    assert_equal "Geocoder::Result::Nominatim", v.result_class.to_s
  end
end
