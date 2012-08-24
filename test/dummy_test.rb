require 'test_helper'
require 'geocoder/lookups/dummy'

class ServicesTest < Test::Unit::TestCase
  RESULT_DATA = {
    'address'     => 'Madison Square Garden, West 31st Street, Long Island City, New York City, New York, 10001, United States of America',
    'city'        => 'New York City',
    'state'       => 'New York',
    'country'     => 'United States of America',
    'postal_code' => '10001'
  }

  def test_dummy_address
    expected = 'Madison Square Garden, New York, NY'
    result = Geocoder::Result::Dummy.new 'address' => expected
    assert_equal expected, result.address
  end

  def test_dummy_city
    expected = 'New York City'
    result = Geocoder::Result::Dummy.new 'city' => expected
    assert_equal expected, result.city
  end

  def test_dummy_state
    expected = 'New York'
    result = Geocoder::Result::Dummy.new 'state' => expected
    assert_equal expected, result.state
  end

  def test_dummy_country
    expected = 'United States of America'
    result = Geocoder::Result::Dummy.new 'country' => expected
    assert_equal expected, result.country
  end

  def test_dummy_postal_code
    expected = '10001'
    result = Geocoder::Result::Dummy.new 'postal_code' => expected
    assert_equal expected, result.postal_code
  end

  def test_dummy_latitude
    expected = 45.423733
    result = Geocoder::Result::Dummy.new 'latitude' => expected
    assert_equal expected, result.latitude
  end

  def test_dummy_longitude
    expected = -75.676333
    result = Geocoder::Result::Dummy.new 'longitude' => expected
    assert_equal expected, result.longitude
  end

  def test_dummy_coordinates
    expected = [45.423733, -75.676333]
    result = Geocoder::Result::Dummy.new 'coordinates' => expected
    assert_equal expected, result.coordinates
  end

  def test_dummy_address_data
    expected = {'foo' => 'bar'}
    result = Geocoder::Result::Dummy.new expected
    assert_equal expected, result.address_data
  end

  def test_dummy_add_queries
    query = "Madison Square Garden, New York, NY"
    assert_equal 0, Geocoder::Lookup::Dummy.queries.size
    result = Geocoder::Lookup::Dummy.add_query(query, RESULT_DATA)
    assert_equal 1, Geocoder::Lookup::Dummy.queries.size
    assert_equal result, Geocoder::Lookup::Dummy.queries[query]
  end

  def test_dummy_remove_query
    Geocoder::Lookup::Dummy.add_query "Madison Square Garden, New York, NY", RESULT_DATA
    assert_equal 1, Geocoder::Lookup::Dummy.queries.size
    Geocoder::Lookup::Dummy.remove_query "Madison Square Garden, New York, NY"
    assert_equal 0, Geocoder::Lookup::Dummy.queries.size
  end

  def test_dummy_clear_queries
    Geocoder::Lookup::Dummy.add_query "Madison Square Garden, New York, NY", RESULT_DATA
    assert_equal 1, Geocoder::Lookup::Dummy.queries.size
    Geocoder::Lookup::Dummy.clear_queries
    assert_equal 0, Geocoder::Lookup::Dummy.queries.size
  end

  def test_dummy_result_components
    Geocoder::Configuration.lookup = :dummy
    expected_result = Geocoder::Lookup::Dummy.add_query("Madison Square Garden, New York, NY", RESULT_DATA).first
    actual_result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal expected_result.address, actual_result.address
  end

  def test_dummy_no_results
    Geocoder::Configuration.lookup = :dummy
    results = Geocoder.search("no results")
    assert_equal 0, results.length
  end
end