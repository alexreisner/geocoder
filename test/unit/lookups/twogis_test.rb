# encoding: utf-8
require 'test_helper'

class TwogisTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(lookup: :twogis)
    set_api_key!(:twogis)
  end

  def test_twogis_point
    result = Geocoder.search('Kremlin, Moscow, Russia').first
    assert_equal [55.755836, 37.617774], result.coordinates
  end

  def test_twogis_no_results
    silence_warnings do
      results = Geocoder.search("no results")
      assert_equal 0, results.length
    end
  end

  def test_twogis_no_city
    result = Geocoder.search('chernoe more').first
    assert_equal "", result.city
  end

  def test_twogis_no_country
    result = Geocoder.search('new york').first
    assert_equal "", result.country
  end

  def test_twogis_result_kind
    assert_nothing_raised do
      ["new york", [55.755836, 37.617774], 'chernoe more'].each do |query|
        Geocoder.search(query).first.type
      end
    end
  end

  def test_twogis_result_returns_street_name
    assert_nothing_raised do
      result = Geocoder.search("ohotniy riad 2").first
      assert_equal "улица Охотный Ряд", result.street
    end
  end

  def test_twogis_result_returns_street_address
    assert_nothing_raised do
      result = Geocoder.search("ohotniy riad 2").first
      assert_equal "улица Охотный Ряд, 2", result.street_address
    end
  end

  def test_twogis_result_returns_street_number
    assert_nothing_raised do
      result = Geocoder.search("ohotniy riad 2").first
      assert_equal "2", result.street_number
    end
  end

  def test_twogis_maximum_precision_on_russian_address
    result = Geocoder.search('ohotniy riad 2').first

    assert_equal [55.757261, 37.616732], result.coordinates

    assert_equal "Москва, улица Охотный Ряд, 2",
                 result.address
    assert_equal "Тверской район", result.district
    assert_equal "Москва", result.city
    assert_equal "Москва", result.region
    assert_equal "Россия", result.country
    assert_equal "улица Охотный Ряд, 2", result.street_address
    assert_equal "улица Охотный Ряд", result.street
    assert_equal "2", result.street_number

    assert_equal "building", result.type
    assert_equal "Многофункциональный комплекс", result.purpose_name
    assert_equal "Four Seasons Moscow, отель", result.building_name
  end

  def test_twogis_hydro_object
    result = Geocoder.search('volga river').first

    assert_equal [57.953151, 38.388873], result.coordinates
    assert_equal "", result.address
    assert_equal "", result.district
    assert_equal "Некоузский район", result.district_area
    assert_equal "Россия", result.country
    assert_equal "Ярославская область", result.region
    assert_equal "", result.street_address
    assert_equal "", result.street
    assert_equal "", result.street_number
    assert_equal "adm_div", result.type
    assert_equal "", result.purpose_name
    assert_equal "", result.building_name
    assert_equal "settlement", result.subtype
    assert_equal "Посёлок", result.subtype_specification
    assert_equal "settlement", result.subtype
    assert_equal "Волга", result.name
  end
end
