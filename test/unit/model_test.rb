# encoding: utf-8
require 'test_helper'

class ModelTest < GeocoderTestCase

  def test_geocode_with_block_runs_block
    e = PlaceWithCustomResultsHandling.new(*geocoded_object_params(:msg))
    e.geocode
    assert_match(/[0-9\.,\-]+/, e.coords_string)
  end

  def test_geocode_with_block_doesnt_auto_assign_coordinates
    e = PlaceWithCustomResultsHandling.new(*geocoded_object_params(:msg))
    e.geocode
    assert_nil e.latitude
    assert_nil e.longitude
  end

  def test_reverse_geocode_with_block_runs_block
    e = PlaceReverseGeocodedWithCustomResultsHandling.new(*reverse_geocoded_object_params(:msg))
    e.reverse_geocode
    assert_equal "US", e.country.upcase
  end

  def test_reverse_geocode_with_block_doesnt_auto_assign_address
    e = PlaceReverseGeocodedWithCustomResultsHandling.new(*reverse_geocoded_object_params(:msg))
    e.reverse_geocode
    assert_nil e.address
  end

  def test_units_and_method
    PlaceReverseGeocoded.reverse_geocoded_by :latitude, :longitude, method: :spherical, units: :km
    assert_equal :km,        PlaceReverseGeocoded.geocoder_options[:units]
    assert_equal :spherical, PlaceReverseGeocoded.geocoder_options[:method]
  end

  def test_params
    params = {incude: "cios2"}
    PlaceReverseGeocoded.reverse_geocoded_by :latitude, :longitude, params: params
    assert_equal params,     PlaceReverseGeocoded.geocoder_options[:params]
  end
end
