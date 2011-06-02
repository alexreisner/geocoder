# encoding: utf-8
require 'test_helper'

class ErrorHandlingTest < Test::Unit::TestCase

  def setup
    Geocoder::Configuration.set_defaults
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
    assert_raise(TimeoutError) { Geocoder.search("timeout") }
    Geocoder::Configuration.always_raise = []
  end

  def test_always_raise_socket_error
    Geocoder::Configuration.always_raise = [SocketError]
    assert_raise(SocketError) { Geocoder.search("socket_error") }
    Geocoder::Configuration.always_raise = []
  end
end
