# encoding: utf-8
require 'test_helper'

class AmazonLocationServiceTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(lookup: :amazon_location_service, amazon_location_service: {index_name: "some_index_name"})
  end

  def test_amazon_location_service_geocoding
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Madison Ave, Staten Island, NY, 10314, USA", result.address
    assert_equal "Staten Island", result.city
    assert_equal "New York", result.state
  end

  def test_amazon_location_service_reverse_geocoding
    result = Geocoder.search([45.423733, -75.676333]).first
    assert_equal "Madison Ave, Staten Island, NY, 10314, USA", result.address
    assert_equal "Staten Island", result.city
    assert_equal "New York", result.state
  end
end
