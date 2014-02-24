# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class GooglePremierTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :google_premier)
    set_api_key!(:google_premier)
  end

  def test_result_components
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Manhattan", result.address_components_of_type(:sublocality).first['long_name']
  end

  def test_query_url
    Geocoder.configure(google_premier: {api_key: ["deadbeef", "gme-test", "test-dev"]})
    query = Geocoder::Query.new("Madison Square Garden, New York, NY")
    assert_equal "http://maps.googleapis.com/maps/api/geocode/json?address=Madison+Square+Garden%2C+New+York%2C+NY&channel=test-dev&client=gme-test&language=en&sensor=false&signature=doJvJqX7YJzgV9rJ0DnVkTGZqTg=", query.url
  end
end
