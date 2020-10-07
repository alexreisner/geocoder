# encoding: utf-8
require 'test_helper'

class HttpsTest < GeocoderTestCase

  def test_uses_https_for_secure_query
    Geocoder.configure(:use_https => true)
    g = Geocoder::Lookup::Google.new
    assert_match(/^https:/, g.query_url(Geocoder::Query.new("test")))
  end
end
