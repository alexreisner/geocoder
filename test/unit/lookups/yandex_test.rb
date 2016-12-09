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

  def test_yandex_empty_results
    result = Geocoder.search('black sea').first
    assert_equal "", result.country_code
    assert_equal "", result.country
  end
end
