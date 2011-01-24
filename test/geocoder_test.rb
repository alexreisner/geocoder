require 'test_helper'

class GeocoderTest < Test::Unit::TestCase

  def test_fetch_coordinates
    v = Venue.new(*venue_params(:msg))
    assert_equal [40.750354, -73.993371], v.fetch_coordinates
    assert_equal [40.750354, -73.993371], [v.latitude, v.longitude]
  end

  # sanity check
  def test_distance_between
    assert_equal 69, Geocoder::Calculations.distance_between(0,0, 0,1).round
  end

  # sanity check
  def test_geographic_center
    assert_equal [0.0, 0.5],
      Geocoder::Calculations.geographic_center([[0,0], [0,1]])
    assert_equal [0.0, 1.0],
      Geocoder::Calculations.geographic_center([[0,0], [0,1], [0,2]])
  end

  def test_exception_raised_for_unconfigured_geocoding
    l = Landmark.new("Mount Rushmore", 43.88, -103.46)
    assert_raises GeocoderConfigurationError do
      l.fetch_coordinates
    end
  end
end
