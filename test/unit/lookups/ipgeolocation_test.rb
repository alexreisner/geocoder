# encoding: utf-8
require 'test_helper'

class IpgeolocationTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(
        :api_key => 'ea91e4a4159247fdb0926feae70c2911',
        :ip_lookup => :ipgeolocation,
        :always_raise => :all
    )
  end

  def test_result_on_ip_address_search
    result = Geocoder.search("103.217.177.217").first
    assert result.is_a?(Geocoder::Result::Ipgeolocation)
  end

  def test_result_components
    result = Geocoder.search("103.217.177.217").first
    assert_equal "Pakistan", result.country_name
  end

  def test_all_top_level_api_fields
    result = Geocoder.search("103.217.177.217").first
    assert_equal "103.217.177.217", result.ip
    assert_equal "AS",              result.continent_code
    assert_equal "Asia",            result.continent_name
    assert_equal "PK",              result.country_code2
    assert_equal "Pakistan",        result.country_name
    assert_equal "Islamabad",       result.city
    assert_equal "44000",           result.zipcode
    assert_equal 33.7334,           result.latitude
    assert_equal 73.0785,           result.longitude
  end

  def test_nested_api_fields
    result = Geocoder.search("103.217.177.217").first

    assert result.time_zone.is_a?(Hash)
    assert_equal "Asia/Karachi", result.time_zone['name']

    assert result.currency.is_a?(Hash)
    assert_equal "PKR", result.currency['code']
  end

  def test_required_base_fields
    result = Geocoder.search("103.217.177.217").first

    assert_equal "Islamabad",        result.country_capital
    assert_equal "Islamabad",        result.state_prov
    assert_equal "Islamabad",        result.city
    assert_equal "44000",            result.zipcode
    assert_equal [33.7334, 73.0785], result.coordinates
  end

  def test_localhost_loopback
    result = Geocoder.search("127.0.0.1").first
    assert_equal "127.0.0.1", result.ip
    assert_equal "RD",        result.country_code2
    assert_equal "Reserved",  result.country_name
  end

  def test_localhost_loopback_defaults
    result = Geocoder.search("127.0.0.1").first

    assert_equal "127.0.0.1", result.ip
    assert_equal "",          result.continent_code
    assert_equal "",          result.continent_name
    assert_equal "RD",          result.country_code2
    assert_equal "Reserved",  result.country_name
    assert_equal "",          result.city
    assert_equal "",          result.zipcode
    assert_equal 0,           result.latitude
    assert_equal 0,           result.longitude
    assert_equal({},          result.time_zone)
    assert_equal({},          result.currency)
  end

  def test_localhost_private
    result = Geocoder.search("172.19.0.1").first
    assert_equal "172.19.0.1", result.ip
    assert_equal "RD",           result.country_code2
    assert_equal "Reserved",   result.country_name
  end

  def test_api_request_adds_access_key
    lookup = Geocoder::Lookup.get(:ipgeolocation)
    assert_match(/apiKey=\w+/, lookup.query_url(Geocoder::Query.new("74.200.247.59")))
  end

  def test_api_request_adds_security_when_specified
    lookup = Geocoder::Lookup.get(:ipgeolocation)
    query_url = lookup.query_url(Geocoder::Query.new("74.200.247.59", params: { security: '1' }))
    assert_match(/&security=1/, query_url)
  end

  def test_api_request_adds_hostname_when_specified
    lookup = Geocoder::Lookup.get(:ipgeolocation)
    query_url = lookup.query_url(Geocoder::Query.new("74.200.247.59", params: { hostname: '1' }))
    assert_match(/&hostname=1/, query_url)
  end

  def test_api_request_adds_language_when_specified
    lookup = Geocoder::Lookup.get(:ipgeolocation)
    query_url = lookup.query_url(Geocoder::Query.new("74.200.247.59", params: { language: 'es' }))
    assert_match(/&language=es/, query_url)
  end

  def test_api_request_adds_fields_when_specified
    lookup = Geocoder::Lookup.get(:ipgeolocation)
    query_url = lookup.query_url(Geocoder::Query.new("74.200.247.59", params: { fields: 'foo,bar' }))
    assert_match(/&fields=foo%2Cbar/, query_url)
  end
end
