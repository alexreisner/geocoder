# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..")
require 'test_helper'

class ErrorHandlingTest < GeocoderTestCase

  def teardown
    Geocoder.configure(:always_raise => [])
  end

  def test_does_not_choke_on_timeout
    silence_warnings do
      Geocoder::Lookup.all_services_except_test.each do |l|
        Geocoder.configure(:lookup => l)
        set_api_key!(l)
        assert_nothing_raised { Geocoder.search("timeout") }
      end
    end
  end

  def test_always_raise_timeout_error
    Geocoder.configure(:always_raise => [TimeoutError])
    Geocoder::Lookup.all_services_except_test.each do |l|
      next if l == :maxmind_local # local, does not raise timeout
      lookup = Geocoder::Lookup.get(l)
      set_api_key!(l)
      assert_raises TimeoutError do
        lookup.send(:results, Geocoder::Query.new("timeout"))
      end
    end
  end

  def test_always_raise_socket_error
    Geocoder.configure(:always_raise => [SocketError])
    Geocoder::Lookup.all_services_except_test.each do |l|
      next if l == :maxmind_local # local, does not raise timeout
      lookup = Geocoder::Lookup.get(l)
      set_api_key!(l)
      assert_raises SocketError do
        lookup.send(:results, Geocoder::Query.new("socket_error"))
      end
    end
  end

  def test_always_raise_connection_refused_error
    Geocoder.configure(:always_raise => [Errno::ECONNREFUSED])
    Geocoder::Lookup.all_services_except_test.each do |l|
      next if l == :maxmind_local # local, does not raise timeout
      lookup = Geocoder::Lookup.get(l)
      set_api_key!(l)
      assert_raises Errno::ECONNREFUSED do
        lookup.send(:results, Geocoder::Query.new("connection_refused"))
      end
    end
  end
end
