# encoding: utf-8
require 'pathname'
require 'rubygems'
require 'test/unit'
require 'geocoder'
require 'yaml'

class HttpClientTest < Test::Unit::TestCase
  def setup
    @api_keys = YAML.load_file("api_keys.yml")
  end

  def test_http_basic_auth
    Geocoder.configure(lookup: :geocoder_us, api_key: @api_keys["geocoder_us"])
    results = Geocoder.search "27701"
    assert_not_nil results.first
  end

  def test_ssl
    Geocoder.configure(lookup: :esri, use_https: true)
    results = Geocoder.search "27701"
    assert_not_nil results.first
  end

  def test_ssl_opt_out
    Geocoder.configure(ip_lookup: :telize, use_https: true)
    results = Geocoder.search "74.200.247.59"
    assert_not_nil results.first
  end
end
