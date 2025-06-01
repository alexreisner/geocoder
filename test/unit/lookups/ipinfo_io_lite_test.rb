require 'test_helper'

class IpinfoIoLiteTest < GeocoderTestCase
  def test_ipinfo_io_lite_lookup_loopback_address
    Geocoder.configure(ip_lookup: :ipinfo_io_lite)
    result = Geocoder.search('127.0.0.1').first
    assert_equal '127.0.0.1', result.ip
  end

  def test_ipinfo_io_lite_lookup_private_address
    Geocoder.configure(ip_lookup: :ipinfo_io_lite)
    result = Geocoder.search('172.19.0.1').first
    assert_equal '172.19.0.1', result.ip
  end

  def test_ipinfo_io_lite_extra_attributes
    Geocoder.configure(ip_lookup: :ipinfo_io_lite, use_https: true)
    result = Geocoder.search('8.8.8.8').first
    assert_equal '8.8.8.8', result.ip
    assert_equal 'US', result.country_code
    assert_equal 'United States', result.country
    assert_equal 'North America', result.continent
    assert_equal 'NA', result.continent_code
    assert_equal 'Google LLC', result.as_name
  end
end
