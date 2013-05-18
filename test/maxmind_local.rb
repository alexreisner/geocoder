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
  end
end