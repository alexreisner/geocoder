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
    assert_raises Geocoder::ConfigurationError do
      l.fetch_coordinates
    end
  end

  def test_result_address_components_of_type
    results = Geocoder::Lookup.search("Madison Square Garden, New York, NY")
    assert_equal "Manhattan",
      results.first.address_components_of_type(:sublocality).first['long_name']
  end
  
  def test_format_of_the_result
    result = Geocoder::Lookup.address(40.750354, -73.993371)
    assert_equal "4 Penn Plaza, New York, NY 10001, USA", result
    
    result = Geocoder::Lookup.address(40.750354, -73.993371, :administrative_area_level_2)
    assert_equal "New York, USA", result
  end
  
  def test_non_existing_format_of_the_result
    result = Geocoder::Lookup.address(40.750354, -73.993371, :house_number)
    assert_equal nil, result
  end
end
