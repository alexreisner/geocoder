# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class HereTest < GeocoderTestCase
  def setup
    Geocoder.configure(lookup: :here)
    set_api_key!(:here)
  end

  def test_here_viewport
    result = Geocoder.search('Madison Square Garden, New York, NY').first
    assert_equal [40.7493451, -73.9948616, 40.7515934, -73.9918938],
                 result.viewport
  end

  def test_here_query_url_contains_country
    lookup = Geocoder::Lookup::Here.new
    url = lookup.query_url(
      Geocoder::Query.new(
        'Some Intersection',
        country: 'GBR'
      )
    )
    assert_match(/country=GBR/, url)
  end

  def test_here_query_url_contains_mapview
    lookup = Geocoder::Lookup::Here.new
    url = lookup.query_url(
      Geocoder::Query.new(
        'Some Intersection',
        bounds: [[40.0, -120.0], [39.0, -121.0]]
      )
    )
    assert_match(/mapview=40.0+%2C-120.0+%3B39.0+%2C-121.0+/, url)
  end

  def test_here_use_autocomplete_query_url
    lookup = Geocoder::Lookup::Here.new
    url = lookup.query_url(
      Geocoder::Query.new(
        'Some Intersection',
        complete: true
      )
    )
    assert_match(/autocomplete.geocoder.api.here.com/, url)
  end

end
