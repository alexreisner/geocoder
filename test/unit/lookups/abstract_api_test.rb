# encoding: utf-8
require 'test_helper'

class AbstractApiTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(ip_lookup: :abstract_api)
    set_api_key!(:abstract_api)
  end

  def test_result_attributes
    result = Geocoder.search('2.19.128.50').first
    assert_equal 'Seattle, WA 98111, United States', result.address
    assert_equal 'Seattle', result.city
    assert_equal 'WA', result.state_code
    assert_equal 'Washington', result.state
    assert_equal 'United States', result.country
    assert_equal 'US', result.country_code
    assert_equal '98111', result.postal_code
    assert_equal 47.6032, result.latitude
    assert_equal(-122.3412, result.longitude)
    assert_equal [47.6032, -122.3412], result.coordinates
  end
end
