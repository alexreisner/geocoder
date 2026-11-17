require 'test_helper'

class InternetdataTest < GeocoderTestCase
  def test_internetdata_lookup_loopback_address
    Geocoder.configure(ip_lookup: :internetdata)
    result = Geocoder.search('127.0.0.1').first
    assert_equal '127.0.0.1', result.ip
    assert result.bogon?
  end

  def test_internetdata_lookup_private_address
    Geocoder.configure(ip_lookup: :internetdata)
    result = Geocoder.search('172.19.0.1').first
    assert_equal '172.19.0.1', result.ip
  end

  def test_internetdata_without_key
    Geocoder.configure(ip_lookup: :internetdata, api_key: nil)
    result = Geocoder.search('8.8.8.8').first
    assert_equal '8.8.8.8', result.ip
    assert_equal 'US', result.country_code
    assert_equal 'United States', result.country
    assert_equal 'America/Los_Angeles', result.time_zone
    assert_equal 15169, result.asn
    assert_equal 'Google LLC', result.company_name
    assert_equal 'dns.google', result.hostname
    assert_nil result.city
    assert_equal [nil, nil], result.coordinates
  end

  def test_internetdata_with_paid_key
    Geocoder.configure(ip_lookup: :internetdata, api_key: 'abc123')
    result = Geocoder.search('146.70.116.130').first
    assert_equal 'Vienna', result.city
    assert_equal 'AT-9', result.state_code
    assert_equal 'AT', result.country_code
    assert_equal 'Vienna, Vienna, Austria', result.address
    assert_in_delta 48.20849, result.latitude, 0.0001
  end

  def test_internetdata_query_url
    Geocoder.configure(ip_lookup: :internetdata, api_key: nil)
    query = Geocoder::Query.new('8.8.8.8')
    assert_equal 'https://api.internetdata.io/8.8.8.8', query.url
    Geocoder.configure(ip_lookup: :internetdata, api_key: 'abc123')
    query = Geocoder::Query.new('8.8.8.8')
    assert_equal 'https://api.internetdata.io/8.8.8.8?apikey=abc123', query.url
  end
end
