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
end
