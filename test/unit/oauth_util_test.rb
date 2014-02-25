# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..")
require 'test_helper'
require 'cgi'
require 'uri'

class OauthUtilTest < GeocoderTestCase
  def test_query_string_escapes_single_quote
    base_url = "http://example.com?location=d'iberville"

    o = OauthUtil.new
    o.consumer_key = 'consumer_key'
    o.consumer_secret = 'consumer_secret'

    query_string = o.sign(URI.parse(base_url)).query_string

    assert_match "location=d%27iberville", query_string
  end

  def test_query_string_sorts_url_keys
    base_url = "http://example.com?a_param=a&z_param=b&b_param=c&n_param=d"

    o = OauthUtil.new
    o.consumer_key = 'consumer_key'
    o.consumer_secret = 'consumer_secret'

    query_string = o.sign(URI.parse(base_url)).query_string

    assert_match(/.*a_param=.*b_param=.*n_param=.*z_param=.*/, query_string)
  end
end
