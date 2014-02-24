# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class MaxmindTest < GeocoderTestCase

  def setup
    Geocoder.configure(ip_lookup: :maxmind)
  end

  def test_maxmind_result_on_ip_address_search
    Geocoder.configure(maxmind: {service: :city_isp_org})
    result = Geocoder.search("74.200.247.59").first
    assert result.is_a?(Geocoder::Result::Maxmind)
  end

  def test_maxmind_result_knows_country_service_name
    Geocoder.configure(maxmind: {service: :country})
    assert_equal :country, Geocoder.search("24.24.24.21").first.service_name
  end

  def test_maxmind_result_knows_city_service_name
    Geocoder.configure(maxmind: {service: :city})
    assert_equal :city, Geocoder.search("24.24.24.22").first.service_name
  end

  def test_maxmind_result_knows_city_isp_org_service_name
    Geocoder.configure(maxmind: {service: :city_isp_org})
    assert_equal :city_isp_org, Geocoder.search("24.24.24.23").first.service_name
  end

  def test_maxmind_result_knows_omni_service_name
    Geocoder.configure(maxmind: {service: :omni})
    assert_equal :omni, Geocoder.search("24.24.24.24").first.service_name
  end

  def test_maxmind_special_result_components
    Geocoder.configure(maxmind: {service: :omni})
    result = Geocoder.search("24.24.24.24").first
    assert_equal "Road Runner", result.isp_name
    assert_equal "Cable/DSL", result.netspeed
    assert_equal "rr.com", result.domain
  end

  def test_maxmind_raises_exception_when_service_not_configured
    Geocoder.configure(maxmind: {service: nil})
    assert_raises Geocoder::ConfigurationError do
      Geocoder::Query.new("24.24.24.24").url
    end
  end

  def test_maxmind_works_when_loopback_address_on_omni
    Geocoder.configure(maxmind: {service: :omni})
    result = Geocoder.search("127.0.0.1").first
    assert_equal "", result.country_code
  end

  def test_maxmind_works_when_loopback_address_on_country
    Geocoder.configure(maxmind: {service: :country})
    result = Geocoder.search("127.0.0.1").first
    assert_equal "", result.country_code
  end
end
