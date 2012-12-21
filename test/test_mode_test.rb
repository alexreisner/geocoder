require 'test_helper'

class TestModeTest < Test::Unit::TestCase

  def setup
    @_original_lookup = Geocoder.config.lookup
    Geocoder.configure(:lookup => :test)
  end

  def teardown
    Geocoder::Lookup::Test.reset
    Geocoder.configure(:lookup => @_original_lookup)
  end

  def test_search_with_known_stub
    coordinates = [40.7143528, -74.0059731]
    attributes = {
      'coordinates'  => coordinates,
      'latitude'     => coordinates[0],
      'longitude'    => coordinates[1],
      'address'      => 'New York, NY, USA',
      'state'        => 'New York',
      'state_code'   => 'NY',
      'country'      => 'United States',
      'country_code' => 'US',
    }

    Geocoder::Lookup::Test.add_stub("New York, NY", [attributes])

    results = Geocoder.search("New York, NY")
    assert_equal 1, results.size

    result = results.first
    assert_equal coordinates,                result.coordinates
    assert_equal attributes['latitude'],     result.latitude
    assert_equal attributes['longitude'],    result.longitude
    assert_equal attributes['address'],      result.address
    assert_equal attributes['state'],        result.state
    assert_equal attributes['state_code'],   result.state_code
    assert_equal attributes['country'],      result.country
    assert_equal attributes['country_code'], result.country_code
  end

  def test_search_with_unknown_stub
    assert_raise ArgumentError do
      Geocoder.search("New York, NY")
    end
  end

end
