# encoding: utf-8
require 'test_helper'

class MaxmindGeoip2Test < GeocoderTestCase
  def setup
    Geocoder.configure(ip_lookup: :maxmind_geoip2)
  end

  def test_result_attributes
    result = Geocoder.search('1.2.3.4').first
    assert_equal 'Los Angeles, CA 90001, United States', result.address
    assert_equal 'Los Angeles', result.city
    assert_equal 'CA', result.state_code
    assert_equal 'California', result.state
    assert_equal 'United States', result.country
    assert_equal 'US', result.country_code
    assert_equal '90001', result.postal_code
    assert_equal(37.6293, result.latitude)
    assert_equal(-122.1163, result.longitude)
    assert_equal [37.6293, -122.1163], result.coordinates
  end

  def test_loopback
    results = Geocoder.search('127.0.0.1')
    assert_equal [], results
  end

  def test_no_results
    results = Geocoder.search("no results")
    assert_equal 0, results.length
  end

  def test_dynamic_localization
    result = Geocoder.search('1.2.3.4').first

    result.language = :ru

    assert_equal 'Лос-Анджелес', result.city
    assert_equal 'Калифорния', result.state
    assert_equal 'США', result.country
  end

  def test_dynamic_localization_fallback
    result = Geocoder.search('1.2.3.4').first

    result.language = :unsupported_language

    assert_equal 'Los Angeles', result.city
    assert_equal 'California', result.state
    assert_equal 'United States', result.country
  end
end
