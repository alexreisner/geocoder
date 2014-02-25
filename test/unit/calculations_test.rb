# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..")
require 'test_helper'

class CalculationsTest < GeocoderTestCase
  def setup
    Geocoder.configure(
      :units => :mi,
      :distances => :linear
    )
  end

  # --- degree distance ---

  def test_longitude_degree_distance_at_equator
    assert_equal 69, Geocoder::Calculations.longitude_degree_distance(0).round
  end

  def test_longitude_degree_distance_at_new_york
    assert_equal 53, Geocoder::Calculations.longitude_degree_distance(40).round
  end

  def test_longitude_degree_distance_at_north_pole
    assert_equal 0, Geocoder::Calculations.longitude_degree_distance(89.98).round
  end


  # --- distance between ---

  def test_distance_between_in_miles
    assert_equal 69, Geocoder::Calculations.distance_between([0,0], [0,1]).round
    la_to_ny = Geocoder::Calculations.distance_between([34.05,-118.25], [40.72,-74]).round
    assert (la_to_ny - 2444).abs < 10
  end

  def test_distance_between_in_kilometers
    assert_equal 111, Geocoder::Calculations.distance_between([0,0], [0,1], :units => :km).round
    la_to_ny = Geocoder::Calculations.distance_between([34.05,-118.25], [40.72,-74], :units => :km).round
    assert (la_to_ny - 3942).abs < 10
  end

  def test_distance_between_in_nautical_miles
    assert_equal 60, Geocoder::Calculations.distance_between([0,0], [0,1], :units => :nm).round
    la_to_ny = Geocoder::Calculations.distance_between([34.05,-118.25], [40.72,-74], :units => :nm).round
    assert (la_to_ny - 2124).abs < 10
  end


  # --- geographic center ---

  def test_geographic_center_with_arrays
    assert_equal [0.0, 0.5],
      Geocoder::Calculations.geographic_center([[0,0], [0,1]])
    assert_equal [0.0, 1.0],
      Geocoder::Calculations.geographic_center([[0,0], [0,1], [0,2]])
  end

  def test_geographic_center_with_mixed_arguments
    p1 = [0, 0]
    p2 = PlaceReverseGeocoded.new("Some Cold Place", 0, 1)
    assert_equal [0.0, 0.5], Geocoder::Calculations.geographic_center([p1, p2])
  end


  # --- bounding box ---

  def test_bounding_box_calculation_in_miles
    center = [51, 7] # Cologne, DE
    radius = 10 # miles
    corners = [50.86, 6.77, 51.14, 7.23]
    assert_equal corners.map{ |i| (i * 100).round },
      Geocoder::Calculations.bounding_box(center, radius).map{ |i| (i * 100).round }
  end

  def test_bounding_box_calculation_in_kilometers
    center = [51, 7] # Cologne, DE
    radius = 111 # kilometers (= 1 degree latitude)
    corners = [50, 5.41, 52, 8.59]
    assert_equal corners.map{ |i| (i * 100).round },
      Geocoder::Calculations.bounding_box(center, radius, :units => :km).map{ |i| (i * 100).round }
  end

  def test_bounding_box_calculation_with_object
    center = [51, 7] # Cologne, DE
    radius = 10 # miles
    corners = [50.86, 6.77, 51.14, 7.23]
    obj = PlaceReverseGeocoded.new("Cologne", center[0], center[1])
    assert_equal corners.map{ |i| (i * 100).round },
      Geocoder::Calculations.bounding_box(obj, radius).map{ |i| (i * 100).round }
  end

  def test_bounding_box_calculation_with_address_string
    assert_nothing_raised do
      Geocoder::Calculations.bounding_box("4893 Clay St, San Francisco, CA", 50)
    end
  end

  # --- random point ---

  def test_random_point_within_radius
    20.times do
      center = [51, 7] # Cologne, DE
      radius = 10 # miles
      random_point = Geocoder::Calculations.random_point_near(center, radius)
      distance = Geocoder::Calculations.distance_between(center, random_point)
      assert distance <= radius
    end
  end

  # --- bearing ---

  def test_compass_points
    assert_equal "N",  Geocoder::Calculations.compass_point(0)
    assert_equal "N",  Geocoder::Calculations.compass_point(1.0)
    assert_equal "N",  Geocoder::Calculations.compass_point(360)
    assert_equal "N",  Geocoder::Calculations.compass_point(361)
    assert_equal "N",  Geocoder::Calculations.compass_point(-22)
    assert_equal "NW", Geocoder::Calculations.compass_point(-23)
    assert_equal "S",  Geocoder::Calculations.compass_point(180)
    assert_equal "S",  Geocoder::Calculations.compass_point(181)
  end

  def test_bearing_between
    bearings = {
      :n => 0,
      :e => 90,
      :s => 180,
      :w => 270
    }
    points = {
      :n => [41, -75],
      :e => [40, -74],
      :s => [39, -75],
      :w => [40, -76]
    }
    directions = [:n, :e, :s, :w]
    methods = [:linear, :spherical]

    methods.each do |m|
      directions.each_with_index do |d,i|
        opp = directions[(i + 2) % 4] # opposite direction
        b = Geocoder::Calculations.bearing_between(
          points[d], points[opp], :method => m)
        assert (b - bearings[opp]).abs < 1,
          "Bearing (#{m}) should be close to #{bearings[opp]} but was #{b}."
      end
    end
  end

  def test_spherical_bearing_to
    l = PlaceReverseGeocoded.new(*reverse_geocoded_object_params(:msg))
    assert_equal 324, l.bearing_to([50,-85], :method => :spherical).round
  end

  def test_spherical_bearing_from
    l = PlaceReverseGeocoded.new(*reverse_geocoded_object_params(:msg))
    assert_equal 136, l.bearing_from([50,-85], :method => :spherical).round
  end

  def test_linear_bearing_from_and_to_are_exactly_opposite
    l = PlaceReverseGeocoded.new(*reverse_geocoded_object_params(:msg))
    assert_equal l.bearing_from([50,-86.1]), l.bearing_to([50,-86.1]) - 180
  end

  def test_extract_coordinates
    coords = [-23,47]
    l = PlaceReverseGeocoded.new("Madagascar", coords[0], coords[1])
    assert_equal coords, Geocoder::Calculations.extract_coordinates(l)
    assert_equal coords, Geocoder::Calculations.extract_coordinates(coords)
  end

  def test_extract_nan_coordinates
    result = Geocoder::Calculations.extract_coordinates([ nil, nil ])
    assert_nan_coordinates?(result)

    result = Geocoder::Calculations.extract_coordinates(nil)
    assert_nan_coordinates?(result)

    result = Geocoder::Calculations.extract_coordinates('')
    assert_nan_coordinates?(result)

    result = Geocoder::Calculations.extract_coordinates([ 'nix' ])
    assert_nan_coordinates?(result)

    o = Object.new
    result = Geocoder::Calculations.extract_coordinates(o)
    assert_nan_coordinates?(result)
  end

  def test_coordinates_present
    assert Geocoder::Calculations.coordinates_present?(3.23)
    assert !Geocoder::Calculations.coordinates_present?(nil)
    assert !Geocoder::Calculations.coordinates_present?(Geocoder::Calculations::NAN)
    assert !Geocoder::Calculations.coordinates_present?(3.23, nil)
  end

  private # ------------------------------------------------------------------

  def assert_nan_coordinates?(value)
    assert value.is_a?(Array) &&
      value.size == 2 &&
      value[0].nan? &&
      value[1].nan?,
      "Expected value to be [NaN, NaN] but was #{value}"
  end

  def test_endpoint
    # test 5 time with random coordinates and headings
    [0..5].each do |i|
      rheading = [*0..359].sample
      rdistance = [*0..100].sample
      startpoint = [45.0906, 7.6596]
      endpoint = Geocoder::Calculations.endpoint(startpoint, rheading, rdistance)
      assert_in_delta rdistance, 
        Geocoder::Calculations.distance_between(startpoint, endpoint, :method => :spherical), 1E-5
      assert_in_delta rheading, 
        Geocoder::Calculations.bearing_between(startpoint, endpoint, :method => :spherical), 1E-2
    end
  end
end
