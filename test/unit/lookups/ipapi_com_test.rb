# encoding: utf-8
require 'test_helper'

class IpapiComTest < GeocoderTestCase

  def setup
    Geocoder::Configuration.instance.data.clear
    Geocoder::Configuration.set_defaults
    Geocoder.configure(ip_lookup: :ipapi_com)
  end

  def test_result_on_ip_address_search
    result = Geocoder.search("74.200.247.59").first
    assert result.is_a?(Geocoder::Result::IpapiCom)
  end

  def test_result_components
    result = Geocoder.search("74.200.247.59").first
    assert_equal "Jersey City, NJ 07302, United States", result.address
  end

  def test_all_api_fields
    result = Geocoder.search("74.200.247.59").first
    assert_equal "United States", result.country
    assert_equal "US", result.country_code
    assert_equal "NJ", result.region
    assert_equal "New Jersey", result.region_name
    assert_equal "Jersey City", result.city
    assert_equal "07302", result.zip
    assert_equal 40.7209, result.lat
    assert_equal -74.0468, result.lon
    assert_equal "America/New_York", result.timezone
    assert_equal "DataPipe", result.isp
    assert_equal "DataPipe", result.org
    assert_equal "AS22576 DataPipe, Inc.", result.as
    assert_equal "", result.reverse
    assert_equal false, result.mobile
    assert_equal false, result.proxy
    assert_equal "74.200.247.59", result.query
    assert_equal "success", result.status
    assert_equal nil, result.message
  end

  def test_localhost
    result = Geocoder.search("::1").first
    assert_equal nil, result.lat
    assert_equal nil, result.lon
    assert_equal [nil, nil], result.coordinates
    assert_equal nil, result.reverse
    assert_equal "::1", result.query
    assert_equal "fail", result.status
  end

  def test_api_key
    Geocoder.configure(:api_key => "MY_KEY")
    g = Geocoder::Lookup::IpapiCom.new
    assert_match "key=MY_KEY", g.query_url(Geocoder::Query.new("74.200.247.59"))
  end

  def test_url_with_api_key_and_fields
    Geocoder.configure(:api_key => "MY_KEY", :ipapi_com => {:fields => "lat,lon,xyz"})
    g = Geocoder::Lookup::IpapiCom.new
    assert_equal "http://pro.ip-api.com/json/74.200.247.59?fields=lat%2Clon%2Cxyz&key=MY_KEY", g.query_url(Geocoder::Query.new("74.200.247.59"))
  end

  def test_url_with_fields
    Geocoder.configure(:ipapi_com => {:fields => "lat,lon"})
    g = Geocoder::Lookup::IpapiCom.new
    assert_equal "http://ip-api.com/json/74.200.247.59?fields=lat%2Clon", g.query_url(Geocoder::Query.new("74.200.247.59"))
  end

  def test_url_without_fields
    g = Geocoder::Lookup::IpapiCom.new
    assert_equal "http://ip-api.com/json/74.200.247.59", g.query_url(Geocoder::Query.new("74.200.247.59"))
  end

  def test_search_with_params
    g = Geocoder::Lookup::IpapiCom.new
    q = Geocoder::Query.new("74.200.247.59", :params => {:fields => 'lat,zip'})
    assert_equal "http://ip-api.com/json/74.200.247.59?fields=lat%2Czip", g.query_url(q)
  end

  def test_use_https_with_api_key
    Geocoder.configure(:api_key => "MY_KEY", :use_https => true)
    g = Geocoder::Lookup::IpapiCom.new
    assert_equal "https://pro.ip-api.com/json/74.200.247.59?key=MY_KEY", g.query_url(Geocoder::Query.new("74.200.247.59"))
  end
end
