# encoding: utf-8
require 'test_helper'

class ResultTest < GeocoderTestCase

  def test_forward_geocoding_result_has_required_attributes
    Geocoder::Lookup.all_services_except_test.each do |l|
      next if l == :ip2location # has pay-per-attribute pricing model
      Geocoder.configure(:lookup => l)
      set_api_key!(l)
      result = Geocoder.search("Madison Square Garden").first
      assert_result_has_required_attributes(result)
    end
  end

  def test_reverse_geocoding_result_has_required_attributes
    Geocoder::Lookup.all_services_except_test.each do |l|
      next if l == :ip2location # has pay-per-attribute pricing model
      Geocoder.configure(:lookup => l)
      set_api_key!(l)
      result = Geocoder.search([45.423733, -75.676333]).first
      assert_result_has_required_attributes(result)
    end
  end

  def test_result_has_coords_in_reasonable_range_for_madison_square_garden
    Geocoder::Lookup.street_services.each do |l|
      next unless File.exist?(File.join("test", "fixtures", "#{l.to_s}_madison_square_garden"))
      Geocoder.configure(:lookup => l)
      set_api_key!(l)
      result = Geocoder.search("Madison Square Garden, New York, NY  10001, United States").first
      assert (result.latitude > 40 and result.latitude < 41), "Lookup #{l} latitude out of range"
      assert (result.longitude > -74 and result.longitude < -73), "Lookup #{l} longitude out of range"
    end
  end

  def test_result_accepts_reverse_coords_in_reasonable_range_for_madison_square_garden
    Geocoder::Lookup.street_services.each do |l|
      next unless File.exist?(File.join("test", "fixtures", "#{l.to_s}_madison_square_garden"))
      next if [:bing, :esri, :geocoder_ca, :google_places_search, :geoportail_lu].include? l # Reverse fixture does not match forward
      Geocoder.configure(:lookup => l)
      set_api_key!(l)
      result = Geocoder.search([40.750354, -73.993371]).first
      assert (["New York", "New York City"].include? result.city), "Reverse lookup #{l} City does not match"
      assert (result.latitude > 40 and result.latitude < 41), "Reverse lookup #{l} latitude out of range"
      assert (result.longitude > -74 and result.longitude < -73), "Reverse lookup #{l} longitude out of range"
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
end
