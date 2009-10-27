require 'test_helper'

class GeocoderTest < Test::Unit::TestCase

  def test_fetch_coordinates
    v = Venue.new(*venue_params(:msg))
    assert_equal [40.7495760, -73.9916733], v.fetch_coordinates
    assert_equal [40.7495760, -73.9916733], [v.latitude, v.longitude]
  end
end
