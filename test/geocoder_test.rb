require 'test_helper'

class GeocoderTest < Test::Unit::TestCase

  def test_fetch_coordinates
    v = Venue.new(*venue_params(:msg))
    assert_equal [40.7495760, -73.9916733], v.fetch_coordinates
    assert_equal [40.7495760, -73.9916733], [v.latitude, v.longitude]
  end
  
  # sanity check
  def test_distance_between
    assert_equal 69, Geocoder.distance_between(0,0, 0,1).round
  end
  
  # sanity check
  def test_geographic_center
    assert_equal [0.0, 0.5],
      Geocoder.geographic_center([[0,0], [0,1]])
    assert_equal [0.0, 1.0],
      Geocoder.geographic_center([[0,0], [0,1], [0,2]])
  end
end
