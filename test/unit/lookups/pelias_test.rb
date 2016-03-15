# encoding: utf-8
require 'test_helper'

class PeliasTest < GeocoderTestCase
  def setup
    Geocoder.configure(lookup: :pelias, api_key: 'abc123', pelias: {}) # Empty pelias hash only for test (pollution control)
  end

  def test_configure_default_endpoint
    query = Geocoder::Query.new('Madison Square Garden, New York, NY')
    assert_true query.url.start_with?('http://localhost/v1/search'), query.url
  end

  def test_configure_custom_endpoint
    Geocoder.configure(lookup: :pelias, api_key: 'abc123', pelias: {endpoint: 'self.hosted.pelias/proxy'})
    query = Geocoder::Query.new('Madison Square Garden, New York, NY')
    assert_true query.url.start_with?('http://self.hosted.pelias/proxy/v1/search'), query.url
  end

  def test_query_url_defaults_to_one
    query = Geocoder::Query.new('Madison Square Garden, New York, NY')
    assert_match 'size=1', query.url
  end
end
