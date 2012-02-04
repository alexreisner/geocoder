require 'test_helper'
require 'geocoder/lookups/test'

class TestModeTest < Test::Unit::TestCase

  def setup
    @_original_lookup = Geocoder::Configuration.lookup
  end

  def teardown
    Geocoder::Lookup::Test.reset
    Geocoder::Configuration.lookup = @_original_lookup
  end

  def test_search_with_known_stub
    Geocoder::Configuration.lookup = :test
    attributes = {
      'latitude'   => 40.7143528,
      'longitude'  => -74.0059731,
      'address'    => 'New York, NY, USA',
      'state'      => 'New York',
      'state_code' => 'NY',
      'country'    => 'United States',
      'country_code' => 'US',
    }
    coordinates = [attributes['latitude'], attributes['longitude']]

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
    Geocoder::Configuration.lookup = :test

    assert_raise ArgumentError do
      Geocoder.search("New York, NY")
    end
  end

end
