# encoding: utf-8
require 'test_helper'

class ErrorHandlingTest < Test::Unit::TestCase

  def teardown
    Geocoder::Configuration.always_raise = []
  end

  def test_does_not_choke_on_timeout
    # keep test output clean: suppress timeout warning
    orig = $VERBOSE; $VERBOSE = nil
    all_lookups.each do |l|
      Geocoder::Configuration.lookup = l
      assert_nothing_raised { Geocoder.search("timeout") }
    end
    $VERBOSE = orig
  end

  def test_always_raise_timeout_error
    Geocoder::Configuration.always_raise = [TimeoutError]
    all_lookups.each do |l|
      lookup = Geocoder.send(:get_lookup, l)
      assert_raises TimeoutError do
        lookup.send(:results, "timeout")
      end
    end
  end

  def test_always_raise_socket_error
    Geocoder::Configuration.always_raise = [SocketError]
    all_lookups.each do |l|
      lookup = Geocoder.send(:get_lookup, l)
      assert_raises SocketError do
        lookup.send(:results, "socket_error")
      end
    end
  end
end
