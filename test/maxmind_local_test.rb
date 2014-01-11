# encoding: utf-8
require 'test_helper'

class MaxmindLocalTest < Test::Unit::TestCase
  def test_it_returns_the_correct_results
    g = Geocoder::Lookup::MaxmindLocal.new

    result = g.search(Geocoder::Query.new('8.8.8.8')).first

    assert_equal result.address, 'Mountain View, CA 94043, United States'
    assert_equal result.city, 'Mountain View'
    assert_equal result.state, 'CA'
    assert_equal result.country, 'United States'
    assert_equal result.country_code, 'USA'
    assert_equal result.postal_code, '94043'
    assert_equal result.latitude, 37.41919999999999
    assert_equal result.longitude, -122.0574
  end

  def test_it_returns_empty_results_when_nothing_is_found
    g = Geocoder::Lookup::MaxmindLocal.new

    result = g.search(Geocoder::Query.new('127.0.0.1'))
    
    assert result.empty?, "Result wasn't empty."
  end
end