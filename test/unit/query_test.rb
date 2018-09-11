# encoding: utf-8
require 'test_helper'

class QueryTest < GeocoderTestCase

  def test_ip_address_detection
    assert Geocoder::Query.new("232.65.123.94").ip_address?
    assert Geocoder::Query.new("3ffe:0b00:0000:0000:0001:0000:0000:000a").ip_address?
    assert !Geocoder::Query.new("232.65.123.94.43").ip_address?
    assert !Geocoder::Query.new("::ffff:123.456.789").ip_address?
  end

  def test_blank_query_detection
    assert Geocoder::Query.new(nil).blank?
    assert Geocoder::Query.new("").blank?
    assert Geocoder::Query.new("\t  ").blank?
    assert !Geocoder::Query.new("a").blank?
    assert !Geocoder::Query.new("Москва").blank? # no ASCII characters
    assert !Geocoder::Query.new("\na").blank?

    assert Geocoder::Query.new(nil, :params => {}).blank?
    assert !Geocoder::Query.new(nil, :params => {:woeid => 1234567}).blank?
  end

  def test_blank_query_detection_for_coordinates
    assert Geocoder::Query.new([nil,nil]).blank?
    assert Geocoder::Query.new([87,nil]).blank?
  end

  def test_coordinates_detection
    assert Geocoder::Query.new("51.178844,5").coordinates?
    assert Geocoder::Query.new("51.178844, -1.826189").coordinates?
    assert !Geocoder::Query.new("232.65.123").coordinates?
    assert !Geocoder::Query.new("Test\n51.178844, -1.826189").coordinates?
  end

  def test_internal_ip_address
    assert Geocoder::Query.new("127.0.0.1").internal_ip_address?
    assert Geocoder::Query.new("172.19.0.1").internal_ip_address?
    assert Geocoder::Query.new("10.100.100.1").internal_ip_address?
    assert Geocoder::Query.new("192.168.0.1").internal_ip_address?
    assert !Geocoder::Query.new("232.65.123.234").internal_ip_address?
  end

  def test_loopback_ip_address
    assert Geocoder::Query.new("127.0.0.1").loopback_ip_address?
    assert !Geocoder::Query.new("232.65.123.234").loopback_ip_address?
  end

  def test_private_ip_address
    assert Geocoder::Query.new("172.19.0.1").private_ip_address?
    assert Geocoder::Query.new("10.100.100.1").private_ip_address?
    assert Geocoder::Query.new("192.168.0.1").private_ip_address?
    assert !Geocoder::Query.new("127.0.0.1").private_ip_address?
    assert !Geocoder::Query.new("232.65.123.234").private_ip_address?
  end

  def test_sanitized_text_with_array
    q = Geocoder::Query.new([43.1313,11.3131])
    assert_equal "43.1313,11.3131", q.sanitized_text
  end

  def test_custom_lookup
    query = Geocoder::Query.new("address", :lookup => :nominatim)
    assert_instance_of Geocoder::Lookup::Nominatim, query.lookup
  end

  def test_force_specify_ip_address
    Geocoder.configure({:ip_lookup => :google})
    query = Geocoder::Query.new("address", {:ip_address => true})
    assert !query.ip_address?
    assert_instance_of Geocoder::Lookup::Google, query.lookup
  end

  def test_force_specify_street_address
    Geocoder.configure({:lookup => :google, :ip_lookup => :freegeoip})
    query = Geocoder::Query.new("4.1.0.2", {street_address: true})
    assert query.ip_address?
    assert_instance_of Geocoder::Lookup::Google, query.lookup
  end

  def test_force_specify_ip_address_with_ip_lookup
    query = Geocoder::Query.new("address", {:ip_address => true, :ip_lookup => :google})
    assert !query.ip_address?
    assert_instance_of Geocoder::Lookup::Google, query.lookup
  end
end
