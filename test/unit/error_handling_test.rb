# encoding: utf-8
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

  def test_always_raise_response_parse_error
    Geocoder.configure(:always_raise => [Geocoder::ResponseParseError])
    [:freegeoip, :google, :ipdata_co, :okf].each do |l|
      lookup = Geocoder::Lookup.get(l)
      set_api_key!(l)
      assert_raises Geocoder::ResponseParseError do
        lookup.send(:results, Geocoder::Query.new("invalid_json"))
      end
    end
  end

  def test_never_raise_response_parse_error
    [:freegeoip, :google, :ipdata_co, :okf].each do |l|
      lookup = Geocoder::Lookup.get(l)
      set_api_key!(l)
      silence_warnings do
        assert_nothing_raised do
          lookup.send(:results, Geocoder::Query.new("invalid_json"))
        end
      end
    end
  end

  def test_always_raise_timeout_error
    Geocoder.configure(:always_raise => [Timeout::Error])
    Geocoder::Lookup.all_services_except_test.each do |l|
      next if l == :maxmind_local || l == :geoip2 # local, does not use cache
      lookup = Geocoder::Lookup.get(l)
      set_api_key!(l)
      assert_raises Timeout::Error do
        lookup.send(:results, Geocoder::Query.new("timeout"))
      end
    end
  end

  def test_always_raise_socket_error
    Geocoder.configure(:always_raise => [SocketError])
    Geocoder::Lookup.all_services_except_test.each do |l|
      next if l == :maxmind_local || l == :geoip2 # local, does not use cache
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
      next if l == :maxmind_local || l == :geoip2 # local, does not use cache
      lookup = Geocoder::Lookup.get(l)
      set_api_key!(l)
      assert_raises Errno::ECONNREFUSED do
        lookup.send(:results, Geocoder::Query.new("connection_refused"))
      end
    end
  end

  def test_always_raise_host_unreachable_error
    Geocoder.configure(:always_raise => [Errno::EHOSTUNREACH])
    Geocoder::Lookup.all_services_except_test.each do |l|
      next if l == :maxmind_local || l == :geoip2 # local, does not use cache
      lookup = Geocoder::Lookup.get(l)
      set_api_key!(l)
      assert_raises Errno::EHOSTUNREACH do
        lookup.send(:results, Geocoder::Query.new("host_unreachable"))
      end
    end
  end
end
