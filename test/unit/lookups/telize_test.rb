# encoding: utf-8
require 'test_helper'

class TelizeTest < GeocoderTestCase

  def setup
    Geocoder.configure(ip_lookup: :telize, telize: {host: nil})
  end

  def test_query_url
    lookup = Geocoder::Lookup::Telize.new
    query = Geocoder::Query.new("74.200.247.59")
    assert_match %r{^https://telize-v1\.p\.mashape\.com/location/74\.200\.247\.59}, lookup.query_url(query)
  end

  def test_includes_api_key_when_set
    Geocoder.configure(api_key: "api_key")
    lookup = Geocoder::Lookup::Telize.new
    query = Geocoder::Query.new("74.200.247.59")
    assert_match %r{/location/74\.200\.247\.59\?mashape-key=api_key}, lookup.query_url(query)
  end

  def test_uses_custom_host_when_set
    Geocoder.configure(telize: {host: "example.com"})
    lookup = Geocoder::Lookup::Telize.new
    query = Geocoder::Query.new("74.200.247.59")
    assert_match %r{^http://example\.com/location/74\.200\.247\.59$}, lookup.query_url(query)
  end

  def test_allows_https_when_custom_host
    Geocoder.configure(use_https: true, telize: {host: "example.com"})
    lookup = Geocoder::Lookup::Telize.new
    query = Geocoder::Query.new("74.200.247.59")
    assert_match %r{^https://example\.com}, lookup.query_url(query)
  end

  def test_requires_https_when_not_custom_host
    Geocoder.configure(use_https: false)
    lookup = Geocoder::Lookup::Telize.new
    query = Geocoder::Query.new("74.200.247.59")
    assert_match %r{^https://telize-v1\.p\.mashape\.com}, lookup.query_url(query)
  end

  def test_result_on_ip_address_search
    result = Geocoder.search("74.200.247.59").first
    assert result.is_a?(Geocoder::Result::Telize)
  end

  def test_result_on_loopback_ip_address_search
    result = Geocoder.search("127.0.0.1").first
    assert_equal "127.0.0.1", result.ip
    assert_equal '',          result.country_code
    assert_equal '',          result.country
  end

  def test_result_on_private_ip_address_search
    result = Geocoder.search("172.19.0.1").first
    assert_equal "172.19.0.1", result.ip
    assert_equal '',           result.country_code
    assert_equal '',           result.country
  end

  def test_result_components
    result = Geocoder.search("74.200.247.59").first
    assert_equal "Jersey City, NJ 07302, United States", result.address
    assert_equal "US", result.country_code
    assert_equal [40.7209, -74.0468], result.coordinates
  end

  def test_no_results
    results = Geocoder.search("8.8.8.8")
    assert_equal 0, results.length
  end

  def test_invalid_address
    results = Geocoder.search("555.555.555.555", ip_address: true)
    assert_equal 0, results.length
  end

  def test_cache_key_strips_off_query_string
    Geocoder.configure(telize: {api_key: "xxxxx"})
    lookup = Geocoder::Lookup.get(:telize)
    query = Geocoder::Query.new("8.8.8.8")
    qurl = lookup.send(:query_url, query)
    key = lookup.send(:cache_key, query)
    assert qurl.include?("mashape-key")
    assert !key.include?("mashape-key")
  end
end
