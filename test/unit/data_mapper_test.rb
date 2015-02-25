# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..")
require 'data_mapper_test_helper'

class DataMapperTest < GeocoderTestCase
  def test_geocoded_check
    p = PlaceUsingDataMapper.new(*geocoded_object_params(:msg))
    p.latitude = 40.750354
    p.longitude = -73.993371
    assert p.geocoded?
  end

  def test_distance_to_returns_float
    p = PlaceUsingDataMapper.new(*geocoded_object_params(:msg))
    p.latitude = 40.750354
    p.longitude = -73.993371
    assert p.distance_to([30, -94]).is_a?(Float)
  end

  def test_model_configuration
    p = PlaceUsingDataMapper.new(*geocoded_object_params(:msg))
    p.latitude = 0
    p.longitude = 0

    PlaceUsingDataMapper.geocoded_by :address, :coordinates => :coordinates, :units => :km
    assert_equal 111, p.distance_to([0,1]).round

    PlaceUsingDataMapper.geocoded_by :address, :coordinates => :coordinates, :units => :mi
    assert_equal 69, p.distance_to([0,1]).round
  end
end
