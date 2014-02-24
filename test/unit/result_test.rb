# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..")
require 'test_helper'

class ResultTest < GeocoderTestCase

  def test_result_has_required_attributes
    Geocoder::Lookup.all_services_except_test.each do |l|
      Geocoder.configure(:lookup => l)
      set_api_key!(l)
      result = Geocoder.search([45.423733, -75.676333]).first
      assert_result_has_required_attributes(result)
    end
  end

  def test_yandex_result_without_city_does_not_raise_exception
    assert_nothing_raised do
      Geocoder.configure(:lookup => :yandex)
      set_api_key!(:yandex)
      result = Geocoder.search("no city and town").first
      assert_equal "", result.city
    end
  end

  def test_yandex_result_new_york
    assert_nothing_raised do
      Geocoder.configure(:lookup => :yandex)
      set_api_key!(:yandex)
      result = Geocoder.search("new york").first
      assert_equal "", result.city
    end
  end

  def test_yandex_result_kind
    assert_nothing_raised do
      Geocoder.configure(:lookup => :yandex)
      set_api_key!(:yandex)
      ["new york", [45.423733, -75.676333], "no city and town"].each do |query|
        Geocoder.search("new york").first.kind
      end
    end
  end

  def test_yandex_result_without_locality_name
    assert_nothing_raised do
      Geocoder.configure(:lookup => :yandex)
      set_api_key!(:yandex)
      result = Geocoder.search("canada rue dupuis 14")[6]
      assert_equal "", result.city
    end
  end

  private # ------------------------------------------------------------------

  def assert_result_has_required_attributes(result)
    m = "Lookup #{Geocoder.config.lookup} does not support %s attribute."
    assert result.coordinates.is_a?(Array),    m % "coordinates"
    assert result.latitude.is_a?(Float),       m % "latitude"
    assert result.longitude.is_a?(Float),      m % "longitude"
    assert result.city.is_a?(String),          m % "city"
    assert result.state.is_a?(String),         m % "state"
    assert result.state_code.is_a?(String),    m % "state_code"
    assert result.province.is_a?(String),      m % "province"
    assert result.province_code.is_a?(String), m % "province_code"
    assert result.postal_code.is_a?(String),   m % "postal_code"
    assert result.country.is_a?(String),       m % "country"
    assert result.country_code.is_a?(String),  m % "country_code"
    assert_not_nil result.address,             m % "address"
  end
end
