$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), *%w[ .. .. lib]))
require 'pathname'
require 'rubygems'
require 'test/unit'
require 'geocoder'

class SmokeTest < Test::Unit::TestCase

  def test_simple_zip_code_search
    result = Geocoder.search "27701"
    assert_not_nil (r = result.first)
    assert_equal "Durham", r.city
    assert_equal "North Carolina", r.state
  end

  def test_simple_zip_code_search_with_ssl
    Geocoder.configure(:use_https => true)
    result = Geocoder.search "27701"
    assert_not_nil (r = result.first)
    assert_equal "Durham", r.city
    assert_equal "North Carolina", r.state
  ensure
    Geocoder.configure(:use_https => false)
  end

end
