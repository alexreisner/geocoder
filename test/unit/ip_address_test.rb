# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..")
require 'test_helper'

class IpAddressTest < GeocoderTestCase

  def test_valid
    assert Geocoder::IpAddress.new("232.65.123.94").valid?
    assert Geocoder::IpAddress.new("666.65.123.94").valid? # technically invalid
    assert Geocoder::IpAddress.new("::ffff:12.34.56.78").valid?
    assert Geocoder::IpAddress.new("3ffe:0b00:0000:0000:0001:0000:0000:000a").valid?
    assert Geocoder::IpAddress.new("::1").valid?
    assert !Geocoder::IpAddress.new("232.65.123.94.43").valid?
    assert !Geocoder::IpAddress.new("232.65.123").valid?
    assert !Geocoder::IpAddress.new("::ffff:123.456.789").valid?
    assert !Geocoder::IpAddress.new("Test\n232.65.123.94").valid?
  end

  def test_loopback
    assert Geocoder::IpAddress.new("0.0.0.0").loopback?
    assert Geocoder::IpAddress.new("127.0.0.1").loopback?
    assert Geocoder::IpAddress.new("::1").loopback?
    assert !Geocoder::IpAddress.new("232.65.123.234").loopback?
    assert !Geocoder::IpAddress.new("127 Main St.").loopback?
    assert !Geocoder::IpAddress.new("John Doe\n127 Main St.\nAnywhere, USA").loopback?
  end
end
