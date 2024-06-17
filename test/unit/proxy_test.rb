# encoding: utf-8
require 'test_helper'

class ProxyTest < GeocoderTestCase

  def test_uses_proxy_when_specified
    Geocoder.configure(:http_proxy => 'localhost')
    lookup = Geocoder::Lookup::Bing.new
    assert lookup.send(:http_client).proxy_class?
  end

  def test_doesnt_use_proxy_when_not_specified
    lookup = Geocoder::Lookup::Bing.new
    assert !lookup.send(:http_client).proxy_class?
  end

  def test_exception_raised_on_bad_proxy_url
    Geocoder.configure(:http_proxy => ' \\_O< Quack Quack')
    assert_raise Geocoder::ConfigurationError do
      Geocoder::Lookup::Bing.new.send(:http_client)
    end
  end

  def test_accepts_proxy_with_http_protocol
    Geocoder.configure(:http_proxy => 'http://localhost')
    lookup = Geocoder::Lookup::Bing.new
    assert lookup.send(:http_client).proxy_class?
  end

  def test_accepts_proxy_with_https_protocol
    Geocoder.configure(:https_proxy => 'https://localhost')
    Geocoder.configure(:use_https => true)
    lookup = Geocoder::Lookup::Google.new
    assert lookup.send(:http_client).proxy_class?
  end
end
