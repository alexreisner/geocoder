# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class YandexTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :yandex)
  end

  def test_yandex_viewport
    result = Geocoder.search('Кремль, Moscow, Russia').first
    assert_equal [55.733361, 37.584182, 55.770517, 37.650064],
      result.viewport
  end

  def test_yandex_no_country_in_results
    result = Geocoder.search('black sea').first
    assert_equal "", result.country_code
    assert_equal "", result.country
  end

  def test_yandex_query_url_contains_bbox
    lookup = Geocoder::Lookup::Yandex.new
    url = lookup.query_url(Geocoder::Query.new(
      "Some Intersection",
      :bounds => [[40.0, -120.0], [39.0, -121.0]]
    ))
    assert_match(/bbox=40.0+%2C-120.0+%7E39.0+%2C-121.0+/, url)
  end
end
