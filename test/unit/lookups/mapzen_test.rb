# encoding: utf-8
require 'test_helper'

class MapzenTest < GeocoderTestCase
  def setup
    Geocoder.configure(lookup: :mapzen, api_key: 'abc123')
  end

  def test_configure_default_endpoint
    query = Geocoder::Query.new('Madison Square Garden, New York, NY')
    assert_true query.url.start_with?('http://search.mapzen.com/v1/search'), query.url
  end

  def test_inherits_from_pelias
    assert_true Geocoder::Lookup::Mapzen.new.is_a?(Geocoder::Lookup::Pelias)
  end
end
