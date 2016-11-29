# encoding: utf-8
require 'test_helper'

class BanDataGouvFrTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :ban_data_gouv_fr)
  end

  def test_query_for_geocode
    query = Geocoder::Query.new('13 rue yves toudic, 75010 Paris')
    lookup = Geocoder::Lookup.get(:ban_data_gouv_fr)
    res = lookup.query_url(query)
    assert_equal 'https://api-adresse.data.gouv.fr/search/?q=13+rue+yves+toudic%2C+75010+Paris', res
  end

  def test_query_for_reverse_geocode
    query = Geocoder::Query.new([48.770639, 2.364375])
    lookup = Geocoder::Lookup.get(:ban_data_gouv_fr)
    res = lookup.query_url(query)
    assert_equal 'https://api-adresse.data.gouv.fr/reverse/?lat=48.770639&lon=2.364375', res
  end

  def test_results_component
    result = Geocoder.search('13 rue yves toudic, 75010 Paris').first
    assert_equal 'ADRNIVX_0000000270748760', result.location_id
    assert_equal 'housenumber', result.result_type
    assert_equal 'Paris', result.city_name
    assert_equal '13 Rue Yves Toudic 75010 Paris, France', result.international_address
    assert_equal '13 Rue Yves Toudic 75010 Paris, France', result.address
    assert_equal '13 Rue Yves Toudic 75010 Paris', result.national_address
    assert_equal '13 Rue Yves Toudic', result.street_address
    assert_equal '13', result.street_number
    assert_equal 'Rue Yves Toudic', result.street
    assert_equal 'Rue Yves Toudic', result.street_name
    assert_equal 'Paris', result.city
    assert_equal 'Paris', result.city_name
    assert_equal '75110', result.city_code
    assert_equal '75010', result.postal_code
    assert_equal '75', result.department_code
    assert_equal 'Paris', result.department_name
    assert_equal 'Île-de-France', result.region_name
    assert_equal 'France', result.country
    assert_equal 'FR', result.country_code
    assert_equal(48.870131, result.coordinates[0])
    assert_equal(2.363473, result.coordinates[1])
  end

  def test_paris_special_business_logic
    result = Geocoder.search('paris').first
    assert_equal 'city', result.result_type
    assert_equal '75000', result.postal_code
    assert_equal 'France', result.country
    assert_equal 'FR', result.country_code
    assert_equal(2244000, result.population)
    assert_equal 'Paris', result.city
    assert_equal 'Paris', result.city_name
    assert_equal '75056', result.city_code
    assert_equal '75000', result.postal_code
    assert_equal '75', result.department_code
    assert_equal 'Paris', result.department_name
    assert_equal 'Île-de-France', result.region_name
    assert_equal(48.8589, result.coordinates[0])
    assert_equal(2.3469, result.coordinates[1])
  end

  def test_city_result_methods
    result = Geocoder.search('montpellier').first
    assert_equal 'city', result.result_type
    assert_equal '34080', result.postal_code
    assert_equal '34172', result.city_code
    assert_equal 'France', result.country
    assert_equal 'FR', result.country_code
    assert_equal(5, result.administrative_weight)
    assert_equal(255100, result.population)
    assert_equal '34', result.department_code
    assert_equal 'Hérault', result.department_name
    assert_equal 'Languedoc-Roussillon', result.region_name
    assert_equal(43.611024, result.coordinates[0])
    assert_equal(3.875521, result.coordinates[1])
  end

  def test_results_component_when_reverse_geocoding
    result = Geocoder.search([48.770431, 2.364463]).first
    assert_equal '94021_1133_49638b', result.location_id
    assert_equal 'housenumber', result.result_type
    assert_equal '4 Rue du Lieutenant Alain le Coz 94550 Chevilly-Larue, France', result.international_address
    assert_equal '4 Rue du Lieutenant Alain le Coz 94550 Chevilly-Larue, France', result.address
    assert_equal '4 Rue du Lieutenant Alain le Coz 94550 Chevilly-Larue', result.national_address
    assert_equal '4 Rue du Lieutenant Alain le Coz', result.street_address
    assert_equal '4', result.street_number
    assert_equal 'Rue du Lieutenant Alain le Coz', result.street
    assert_equal 'Rue du Lieutenant Alain le Coz', result.street_name
    assert_equal 'Chevilly-Larue', result.city
    assert_equal 'Chevilly-Larue', result.city_name
    assert_equal '94021', result.city_code
    assert_equal '94550', result.postal_code
    assert_equal '94', result.department_code
    assert_equal 'Val-de-Marne', result.department_name
    assert_equal 'Île-de-France', result.region_name
    assert_equal 'France', result.country
    assert_equal 'FR', result.country_code
    assert_equal(48.770639, result.coordinates[0])
    assert_equal(2.364375, result.coordinates[1])
  end

  def test_no_reverse_results
    result = Geocoder.search('no reverse results')
    assert_equal 0, result.length
  end

  def test_actual_make_api_request_with_https
    Geocoder.configure(use_https: true, lookup: :ban_data_gouv_fr)

    require 'webmock/test_unit'
    WebMock.enable!
    stub_all = WebMock.stub_request(:any, /.*/).to_return(status: 200)

    g = Geocoder::Lookup::BanDataGouvFr.new
    g.send(:actual_make_api_request, Geocoder::Query.new('test location'))
    assert_requested(stub_all)

    WebMock.reset!
    WebMock.disable!
  end


  private

  def assert_country_code(result)
    [:state_code, :country_code, :province_code].each do |method|
      assert_equal 'FR', result.send(method)
    end
  end
end
