# encoding: utf-8
require 'test_helper'

class GeocodefarmTest < Test::Unit::TestCase

  def setup
    Geocoder.configure(lookup: :geocodefarm)
    set_api_key!(:geocodefarm)
  end

  # def test_query_for_reverse_geocode
  #   lookup = Geocoder::Lookup::Geocodefarm.new
  #   url = lookup.query_url(Geocoder::Query.new([45.423733, -75.676333]))
  #   assert_match /Locations\/45.423733/, url
  # end

  def test_result_components
    result = Geocoder.search("4 Pennsylvania Plaza, New York, NY 10001").first
    assert_equal "4 Pennsylvania Plaza, New York", result.address
    assert_equal "NY", result.state
    assert_equal "New York", result.city
  end

  def test_no_results
    results = Geocoder.search("no results")
    assert_equal 0, results.length
  end
end
