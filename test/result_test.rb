# encoding: utf-8
require 'test_helper'

class ResultTest < Test::Unit::TestCase

  def test_result_has_required_attributes
    Geocoder::Lookup.all_services_except_test.each do |l|
      Geocoder.configure(:lookup => l)
      set_api_key!(l)
      result = Geocoder.search([45.423733, -75.676333]).first
      assert_result_has_required_attributes(result)
    end
  end


  # Redefine Yandex to work with fixture without city and town
  class Yandex
    private
    def default_fixture_filename
      "yandex_no_city_and_town"
    end
  end


  def test_yandex_result_without_city_has_not_raises_exception
    Geocoder.configure(:lookup => :yandex)
    set_api_key!(:yandex)
    result = Geocoder.search([45.423733, -75.676333]).first
    assert result.city, ""
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
