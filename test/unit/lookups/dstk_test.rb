# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class DstkTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :dstk)
  end

  def test_dstk_result_components
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Manhattan", result.address_components_of_type(:sublocality).first['long_name']
  end

  def test_dstk_query_url
    query = Geocoder::Query.new("Madison Square Garden, New York, NY")
    assert_equal "http://www.datasciencetoolkit.org/maps/api/geocode/json?address=Madison+Square+Garden%2C+New+York%2C+NY&language=en&sensor=false", query.url
  end

  def test_dstk_query_url_with_custom_host
    Geocoder.configure(dstk: {host: 'NOT_AN_ACTUAL_HOST'})
    query = Geocoder::Query.new("Madison Square Garden, New York, NY")
    assert_equal "http://NOT_AN_ACTUAL_HOST/maps/api/geocode/json?address=Madison+Square+Garden%2C+New+York%2C+NY&language=en&sensor=false", query.url
  end
end
