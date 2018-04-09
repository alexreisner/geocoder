# encoding: utf-8
require 'test_helper'

class RequestTest < GeocoderTestCase
  class MockRequest < Rack::Request
    include Geocoder::Request
    def initialize(headers={}, ip="")
      super_env = headers
      super_env.merge!({'REMOTE_ADDR' => ip}) unless ip == ""
      super(super_env)
    end
  end

  def setup
    Geocoder.configure(ip_lookup: :freegeoip)
  end

  def test_http_x_real_ip
    req = MockRequest.new({"HTTP_X_REAL_IP" => "74.200.247.59"})
    assert req.location.is_a?(Geocoder::Result::Freegeoip)
  end
  def test_http_x_client_ip
    req = MockRequest.new({"HTTP_X_CLIENT_IP" => "74.200.247.59"})
    assert req.location.is_a?(Geocoder::Result::Freegeoip)
  end
  def test_http_x_cluster_client_ip
    req = MockRequest.new({"HTTP_X_CLUSTER_CLIENT_IP" => "74.200.247.59"})
    assert req.location.is_a?(Geocoder::Result::Freegeoip)
  end
  def test_http_x_forwarded_for_without_proxy
    req = MockRequest.new({"HTTP_X_FORWARDED_FOR" => "74.200.247.59"})
    assert req.location.is_a?(Geocoder::Result::Freegeoip)
  end
  def test_http_x_forwarded_for_with_proxy
    req = MockRequest.new({"HTTP_X_FORWARDED_FOR" => "74.200.247.59, 74.200.247.60"})
    assert req.geocoder_spoofable_ip == '74.200.247.59'
    assert req.ip == '74.200.247.60'
    assert req.location.is_a?(Geocoder::Result::Freegeoip)
    assert_equal "US", req.location.country_code
  end
  def test_safe_http_x_forwarded_for_with_proxy
    req = MockRequest.new({"HTTP_X_FORWARDED_FOR" => "74.200.247.59, 74.200.247.60"})
    assert req.geocoder_spoofable_ip == '74.200.247.59'
    assert req.ip == '74.200.247.60'
    assert req.safe_location.is_a?(Geocoder::Result::Freegeoip)
    assert_equal "MX", req.safe_location.country_code
  end
  def test_with_request_ip
    req = MockRequest.new({}, "74.200.247.59")
    assert req.location.is_a?(Geocoder::Result::Freegeoip)
  end
  def test_with_loopback_x_forwarded_for
    req = MockRequest.new({"HTTP_X_FORWARDED_FOR" => "127.0.0.1"}, "74.200.247.59")
    assert_equal "US", req.location.country_code
  end
  def test_http_x_forwarded_for_with_misconfigured_proxies
    req = MockRequest.new({"HTTP_X_FORWARDED_FOR" => ","}, "74.200.247.59")
    assert req.location.is_a?(Geocoder::Result::Freegeoip)
  end
  def test_non_ip_in_proxy_header
    req = MockRequest.new({"HTTP_X_FORWARDED_FOR" => "Albequerque NM"})
    assert req.location.is_a?(Geocoder::Result::Freegeoip)
  end
  def test_safe_location_after_location
    req = MockRequest.new({"HTTP_X_REAL_IP" => "74.200.247.59"}, "127.0.0.1")
    assert_equal 'US', req.location.country_code
    assert_equal 'RD', req.safe_location.country_code
  end
  def test_location_after_safe_location
    req = MockRequest.new({'HTTP_X_REAL_IP' => '74.200.247.59'}, '127.0.0.1')
    assert_equal 'RD', req.safe_location.country_code
    assert_equal 'US', req.location.country_code
  end
  def test_geocoder_remove_port_from_addresses_with_port
    expected_ips = ['127.0.0.1', '127.0.0.2', '127.0.0.3']
    ips = ['127.0.0.1:3000', '127.0.0.2:8080', '127.0.0.3:9292']
    req = MockRequest.new()
    assert_equal expected_ips, req.send(:geocoder_remove_port_from_addresses, ips)
  end
  def test_geocoder_remove_port_from_ipv6_addresses_with_port
    expected_ips = ['2600:1008:b16e:26da:ecb3:22f7:6be4:2137', '2600:1901:0:2df5::', '2001:db8:1f70::999:de8:7648:6e8', '10.128.0.2']
    ips = ['2600:1008:b16e:26da:ecb3:22f7:6be4:2137', '2600:1901:0:2df5::', '[2001:db8:1f70::999:de8:7648:6e8]:100', '10.128.0.2']
    req = MockRequest.new()
    assert_equal expected_ips, req.send(:geocoder_remove_port_from_addresses, ips)
  end
  def test_geocoder_remove_port_from_addresses_without_port
    expected_ips = ['127.0.0.1', '127.0.0.2', '127.0.0.3']
    ips = ['127.0.0.1', '127.0.0.2', '127.0.0.3']
    req = MockRequest.new()
    assert_equal expected_ips, req.send(:geocoder_remove_port_from_addresses, ips)
  end
  def test_geocoder_reject_non_ipv4_addresses_with_good_ips
    expected_ips = ['127.0.0.1', '127.0.0.2', '127.0.0.3']
    ips = ['127.0.0.1', '127.0.0.2', '127.0.0.3']
    req = MockRequest.new()
    assert_equal expected_ips, req.send(:geocoder_reject_non_ipv4_addresses, ips)
  end
  def test_geocoder_reject_non_ipv4_addresses_with_bad_ips
    expected_ips = ['127.0.0.1']
    ips = ['127.0.0', '127.0.0.1', '127.0.0.2.0']
    req = MockRequest.new()
    assert_equal expected_ips, req.send(:geocoder_reject_non_ipv4_addresses, ips)
  end
end
