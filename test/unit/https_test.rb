# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..")
require 'test_helper'

class HttpsTest < GeocoderTestCase

  def test_uses_https_for_secure_query
    Geocoder.configure(:use_https => true)
    g = Geocoder::Lookup::Google.new
    assert_match(/^https:/, g.query_url(Geocoder::Query.new("test")))
  end

  def test_uses_http_by_default
    g = Geocoder::Lookup::Google.new
    assert_match(/^http:/, g.query_url(Geocoder::Query.new("test")))
  end
end
