# encoding: utf-8
require 'test_helper'

class Ip2locationIoTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(ip_lookup: :ip2location_io)
    set_api_key!(:ip2location_io)
  end

  def test_ip2location_io_query_url
    query = Geocoder::Query.new('8.8.8.8')
    assert_equal 'https://api.ip2location.io/?ip=8.8.8.8&key=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', query.url
  end

  def test_ip2location_lookup_address
    result = Geocoder.search("8.8.8.8").first
    assert_equal "US", result.country_code
    assert_equal "United States of America", result.country_name
    assert_equal "California", result.region_name
    assert_equal "Mountain View", result.city_name
  end

  def test_ip2location_lookup_loopback_address
    result = Geocoder.search("127.0.0.1").first
    assert_equal "-", result.country_code
  end

  def test_ip2location_lookup_private_address
    result = Geocoder.search("172.19.0.1").first
    assert_equal "-", result.country_code
  end
end
