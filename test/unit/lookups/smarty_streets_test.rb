# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class SmartyStreetsTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :smarty_streets)
    set_api_key!(:smarty_streets)
  end

  def test_url_contains_api_key
    Geocoder.configure(:smarty_streets => {:api_key => 'blah'})
    query = Geocoder::Query.new("Bluffton, SC")
    assert_equal "http://api.smartystreets.com/street-address?auth-token=blah&street=Bluffton%2C+SC", query.url
  end

  def test_query_for_address_geocode
    query = Geocoder::Query.new("42 Wallaby Way Sydney, AU")
    assert_match /api\.smartystreets\.com\/street-address\?/, query.url
  end

  def test_query_for_zipcode_geocode
    query = Geocoder::Query.new("22204")
    assert_match /api\.smartystreets\.com\/zipcode\?/, query.url
  end

  def test_query_for_zipfour_geocode
    query = Geocoder::Query.new("22204-1603")
    assert_match /api\.smartystreets\.com\/zipcode\?/, query.url
  end

  def test_smarty_streets_result_components
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Penn", result.street
    assert_equal "10121", result.zipcode
    assert_equal "1703", result.zip4
    assert_equal "New York", result.city
    assert_equal "36061", result.fips
    assert !result.zipcode_result?
  end

  def test_smarty_streets_result_components_with_zipcode_only_query
    result = Geocoder.search("11211").first
    assert_equal "Brooklyn", result.city
    assert_equal "New York", result.state
    assert_equal "NY", result.state_code
    assert result.zipcode_result?
  end

  def test_smarty_streets_dynamic_methods_are_not_exposed
    assert_raises NoMethodError do
      Geocoder.search("Madison Square Garden, New York, NY").first.components
    end
    assert_raises NoMethodError do
      Geocoder.search("Madison Square Garden, New York, NY").first.delivery_line_1
    end
    assert_raises NoMethodError do
      Geocoder.search("11211").first.city_states
    end
  end

  def test_no_results
    results = Geocoder.search("no results")
    assert_equal 0, results.length
  end

end
