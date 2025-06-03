# encoding: utf-8
require 'test_helper'

class ResultTest < GeocoderTestCase

  def test_forward_geocoding_result_has_required_attributes
    Geocoder::Lookup.all_services_except_test.each do |l|
      next if [
        :ip2location, # has pay-per-attribute pricing model
        :ip2location_io, # has pay-per-attribute pricing model
        :ip2location_lite, # no forward geocoding
        :ipinfo_io_lite, # does not support exact location
        :twogis, # cant find 'Madison Square Garden'
      ].include?(l)

      Geocoder.configure(:lookup => l)
      set_api_key!(l)
      result = Geocoder.search("Madison Square Garden").first
      assert_result_has_required_attributes(result)
      assert_aws_result_supports_place_id(result) if l == :amazon_location_service
    end
  end

  def test_reverse_geocoding_result_has_required_attributes
    Geocoder::Lookup.all_services_except_test.each do |l|
      next if [
        :ip2location, # has pay-per-attribute pricing model
        :ip2location_io, # has pay-per-attribute pricing model
        :ip2location_lite, # no reverse geocoding
        :ipinfo_io_lite, # no reverse geocoding
        :nationaal_georegister_nl, # no reverse geocoding
        :melissa_street, # reverse geocoding not implemented
        :twogis, # cant find 'Madison Square Garden'
      ].include?(l)

      Geocoder.configure(:lookup => l)
      set_api_key!(l)
      result = Geocoder.search([45.423733, -75.676333]).first
      assert_result_has_required_attributes(result)
    end
  end

  private # ------------------------------------------------------------------

  def assert_result_has_required_attributes(result)
    m = "Lookup #{Geocoder.config.lookup} does not support %s attribute."
    assert result.coordinates.is_a?(Array),    m % "coordinates"
    assert result.latitude.is_a?(Float),       m % "latitude"
    assert result.latitude != 0.0,             m % "latitude"
    assert result.longitude.is_a?(Float),      m % "longitude"
    assert result.longitude != 0.0,            m % "longitude"
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

  def assert_aws_result_supports_place_id(result)
    assert result.place_id.is_a?(String)
  end
end
