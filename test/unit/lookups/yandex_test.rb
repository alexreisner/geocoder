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
    if RUBY_VERSION < '2.5.0'
      assert_match(/bbox=40.0+%2C-120.0+%7E39.0+%2C-121.0+/, url)
    else
      assert_match(/bbox=40.0+%2C-120.0+~39.0+%2C-121.0+/, url)
    end
  end

  def test_yandex_result_without_city_does_not_raise_exception
    assert_nothing_raised do
      set_api_key!(:yandex)
      result = Geocoder.search("no city and town").first
      assert_equal "", result.city
    end
  end

  def test_yandex_result_without_admin_area_no_exception
    assert_nothing_raised do
      set_api_key!(:yandex)
      result = Geocoder.search("no administrative area").first
      assert_equal "", result.city
    end
  end

  def test_yandex_result_new_york
    assert_nothing_raised do
      set_api_key!(:yandex)
      result = Geocoder.search("new york").first
      assert_equal "", result.city
    end
  end

  def test_yandex_result_kind
    assert_nothing_raised do
      set_api_key!(:yandex)
      ["new york", [45.423733, -75.676333], "no city and town"].each do |query|
        Geocoder.search("new york").first.kind
      end
    end
  end

  def test_yandex_result_without_locality_name
    assert_nothing_raised do
      set_api_key!(:yandex)
      result = Geocoder.search("canada rue dupuis 14")[6]
      assert_equal "", result.city
    end
  end

  def test_yandex_result_returns_street_name
    assert_nothing_raised do
      set_api_key!(:yandex)
      result = Geocoder.search("canada rue dupuis 14")[6]
      assert_equal "Rue Hormidas-Dupuis", result.street
    end
  end

  def test_yandex_result_returns_street_number
    assert_nothing_raised do
      set_api_key!(:yandex)
      result = Geocoder.search("canada rue dupuis 14")[6]
      assert_equal "14", result.street_number
    end
  end
end
