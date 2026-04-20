# encoding: utf-8
require 'test_helper'

class Ip2geoTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(ip_lookup: :ip2geo)
    set_api_key!(:ip2geo)
  end

  def test_ip2geo_lookup_loopback_address
    result = Geocoder.search("127.0.0.1").first
    assert_equal 0, result.coordinates[0]
    assert_equal 0, result.coordinates[1]
    assert_equal "127.0.0.1", result.ip
  end

  def test_ip2geo_lookup_private_address
    result = Geocoder.search("172.19.0.1").first
    assert_equal 0, result.coordinates[0]
    assert_equal 0, result.coordinates[1]
    assert_equal "172.19.0.1", result.ip
  end

  def test_ip2geo_result_attributes
    result = Geocoder.search("8.8.8.8").first
    assert_equal "8.8.8.8", result.ip
    assert_equal "Mountain View", result.city
    assert_equal "California", result.state
    assert_equal "CA", result.state_code
    assert_equal "United States", result.country
    assert_equal "US", result.country_code
    assert_equal "94035", result.postal_code
    assert_equal "America/Los_Angeles", result.timezone
    assert_equal "North America", result.continent
    assert_equal "NA", result.continent_code
    assert_equal 15169, result.asn_number
    assert_equal "Google LLC", result.asn_name
    assert_equal "+1", result.phone_code
    assert_equal "USD", result.currency_code
  end

  def test_ip2geo_result_coordinates
    result = Geocoder.search("8.8.8.8").first
    assert_in_delta 37.386, result.coordinates[0], 0.001
    assert_in_delta(-122.0838, result.coordinates[1], 0.001)
  end
end
