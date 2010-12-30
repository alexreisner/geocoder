require 'test_helper'

class GeocoderTest < Test::Unit::TestCase

  def test_fetch_coordinates
    v = Venue.new(*venue_params(:msg))
    p v
    assert_equal [40.750354, -73.993371], v.fetch_coordinates
    assert_equal [40.750354, -73.993371], [v.latitude, v.longitude]
    assert_equal [40.750354, -73.993371], v.query
  end
  
  def test_fetch_address
    v = Venue.new(*venue_params(:coordinates))
    p v
    assert_equal "4 Penn Plaza, New York, NY 10001, USA", v.fetch_address
    assert_equal "4 Penn Plaza, New York, NY 10001, USA", v.query
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
