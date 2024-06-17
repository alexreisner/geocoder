# encoding: utf-8
require 'test_helper'

class PeliasTest < GeocoderTestCase

  def setup
    super
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

  def test_query_for_reverse_geocode
    lookup = Geocoder::Lookup::Pelias.new
    url = lookup.query_url(Geocoder::Query.new([45.423733, -75.676333]))
    assert_match(/point.lat=45.423733&point.lon=-75.676333/, url)
  end
end
