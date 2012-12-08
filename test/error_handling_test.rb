# encoding: utf-8
require 'test_helper'

class ErrorHandlingTest < Test::Unit::TestCase

  def teardown
    Geocoder.configure(:always_raise => [])
  end

  def test_does_not_choke_on_timeout
    # keep test output clean: suppress timeout warning
    orig = $VERBOSE; $VERBOSE = nil
    Geocoder::Lookup.all_services_except_test.each do |l|
      Geocoder.configure(:lookup => l)
      set_api_key!(l)
      assert_nothing_raised { Geocoder.search("timeout") }
    end
  ensure
    $VERBOSE = orig
  end

  def test_always_raise_timeout_error
    Geocoder.configure(:always_raise => [TimeoutError])
    Geocoder::Lookup.all_services_except_test.each do |l|
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
      lookup = Geocoder::Lookup.get(l)
      set_api_key!(l)
      assert_raises SocketError do
        lookup.send(:results, Geocoder::Query.new("socket_error"))
      end
    end
  end
end
