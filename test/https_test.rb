# encoding: utf-8
require 'test_helper'

class HttpsTest < Test::Unit::TestCase

  def test_uses_https_for_secure_query
    Geocoder::Configuration.use_https = true
    g = Geocoder::Lookup::Google.new
    assert_match /^https:/, g.send(:query_url, {:a => 1, :b => 2})
  end

  def test_uses_http_by_default
    g = Geocoder::Lookup::Google.new
    assert_match /^http:/, g.send(:query_url, {:a => 1, :b => 2})
  end
end
