# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class YandexTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(lookup: :yandex, language: :en)
  end

  def test_yandex_viewport
    result = Geocoder.search('Kremlin, Moscow, Russia').first
    assert_equal [55.748189, 37.612587, 55.755044, 37.623187],
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

  def test_yandex_find_in_hash_method
    result = Geocoder::Result::Yandex.new({})
    hash = {
      'root_node' => {
        'node_1' => [1, 2, 3],
        'node_2' => {
          'data' => 'foo'
        }
      }
    }

    assert_equal [1, 2, 3], result.send(:find_in_hash, hash, 'root_node', 'node_1')
    assert_equal "foo", result.send(:find_in_hash, hash, 'root_node', 'node_2', 'data')
    assert_equal nil, result.send(:find_in_hash, hash, 'root_node', 'node_3')
    assert_equal nil, result.send(:find_in_hash, hash, 'root_node', 'node_2', 'another_data')
    assert_equal nil, result.send(:find_in_hash, hash, 'root_node', 'node_2', 'data', 'x')
  end

  def test_yandex_maximum_precision_on_russian_address
    result = Geocoder.search('putilkovo novotushinskaya 5').first

    assert_equal [55.872258, 37.403522], result.coordinates
    assert_equal [55.86995, 37.399416, 55.874567, 37.407627], result.viewport

    assert_equal "Russia, Moscow Region, gorodskoy okrug Krasnogorsk, " \
                 "derevnya Putilkovo, Novotushinskaya ulitsa, 5",
                 result.address
    assert_equal "derevnya Putilkovo", result.city
    assert_equal "Russia", result.country
    assert_equal "RU", result.country_code
    assert_equal "Moscow Region", result.state
    assert_equal "gorodskoy okrug Krasnogorsk", result.sub_state
    assert_equal "", result.state_code
    assert_equal "Novotushinskaya ulitsa", result.street
    assert_equal "5", result.street_number
    assert_equal "", result.premise_name
    assert_equal "143441", result.postal_code
    assert_equal "house", result.kind
    assert_equal "exact", result.precision
  end

  def test_yandex_hydro_object
    result = Geocoder.search('volga river').first

    assert_equal [49.550996, 45.139984], result.coordinates
    assert_equal [45.697053, 32.468241, 58.194645, 50.181608], result.viewport

    assert_equal "Russia, Volga River", result.address
    assert_equal "", result.city
    assert_equal "Russia", result.country
    assert_equal "RU", result.country_code
    assert_equal "", result.state
    assert_equal "", result.sub_state
    assert_equal "", result.state_code
    assert_equal "", result.street
    assert_equal "", result.street_number
    assert_equal "Volga River", result.premise_name
    assert_equal "", result.postal_code
    assert_equal "hydro", result.kind
    assert_equal "other", result.precision
  end

  def test_yandex_province_object
    result = Geocoder.search('ontario').first

    assert_equal [49.294248, -87.170557], result.coordinates
    assert_equal [41.704494, -95.153382, 56.88699, -74.321387], result.viewport

    assert_equal "Canada, Ontario", result.address
    assert_equal "", result.city
    assert_equal "Canada", result.country
    assert_equal "CA", result.country_code
    assert_equal "Ontario", result.state
    assert_equal "", result.sub_state
    assert_equal "", result.state_code
    assert_equal "", result.street
    assert_equal "", result.street_number
    assert_equal "", result.premise_name
    assert_equal "", result.postal_code
    assert_equal "province", result.kind
    assert_equal "other", result.precision
  end
end
