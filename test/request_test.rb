# encoding: utf-8
require 'test_helper'

class RequestTest < Test::Unit::TestCase
  class MockRequest
    include Geocoder::Request
    attr_accessor :env, :ip
    def initialize(env={}, ip="")
      @env = env
      @ip  = ip
    end
  end
  def test_http_x_real_ip
    req = MockRequest.new({"HTTP_X_REAL_IP" => "74.200.247.59"})
    assert req.location.is_a?(Geocoder::Result::Freegeoip)
  end
  def test_http_x_forwarded_for_without_proxy
    req = MockRequest.new({"HTTP_X_FORWARDED_FOR" => "74.200.247.59"})
    assert req.location.is_a?(Geocoder::Result::Freegeoip)
  end
  def test_http_x_forwarded_for_with_proxy
    req = MockRequest.new({"HTTP_X_FORWARDED_FOR" => "74.200.247.59, 74.200.247.59"})
    assert req.location.is_a?(Geocoder::Result::Freegeoip)
  end
  def test_with_request_ip
    req = MockRequest.new({}, "74.200.247.59")
    assert req.location.is_a?(Geocoder::Result::Freegeoip)
  end
end