# encoding: utf-8
require 'test_helper'

class ConfigurationTest < Test::Unit::TestCase

  def test_exception_raised_on_bad_lookup_config
    Geocoder::Configuration.lookup = :stoopid
    assert_raises Geocoder::ConfigurationError do
      Geocoder.search "something dumb"
    end
  end

end
