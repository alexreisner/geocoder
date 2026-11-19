require 'ipaddr'
require 'test/unit'
require_relative '../../lib/geocoder/request'

class RequestMappedIpv6Test < Test::Unit::TestCase
  class SyntheticRequest
    include Geocoder::Request

    def initialize(ip)
      @env = {
        'HTTP_X_FORWARDED_FOR' => ip,
        'REMOTE_ADDR' => '192.0.2.254'
      }
    end

    def trusted_proxy?(_ip)
      false
    end
  end

  def test_preserves_ipv4_mapped_ipv6_forwarded_address
    ip = '::ffff:192.0.2.1'

    assert_equal IPAddr.new(ip).to_s, SyntheticRequest.new(ip).geocoder_spoofable_ip
  end

  def test_removes_port_from_ipv4_forwarded_address
    ip = '192.0.2.1:8080'

    assert_equal '192.0.2.1', SyntheticRequest.new(ip).geocoder_spoofable_ip
  end

  def test_removes_port_from_bracketed_ipv6_forwarded_address
    ip = '[2001:db8::1]:8080'

    assert_equal '2001:db8::1', SyntheticRequest.new(ip).geocoder_spoofable_ip
  end
end
