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

  def test_amazon_location_service_caching_rehydrates_equivalent_result
    configure_fresh_cache

    first = Geocoder.search("Madison Square Garden, New York, NY").first
    cached = Geocoder.search("Madison Square Garden, New York, NY").first

    assert !first.cache_hit
    assert cached.cache_hit
    assert_equal first.address, cached.address
    assert_equal first.coordinates, cached.coordinates
    assert_equal first.city, cached.city
    assert_equal first.state, cached.state
    assert_equal first.postal_code, cached.postal_code
    assert_equal first.neighborhood, cached.neighborhood
    assert_equal first.place_id, cached.place_id
  end

  def test_amazon_location_service_reverse_geocode_caching
    configure_fresh_cache

    first = Geocoder.search([45.423733, -75.676333]).first
    cached = Geocoder.search([45.423733, -75.676333]).first

    assert !first.cache_hit
    assert cached.cache_hit
    assert_equal first.address, cached.address
    assert_equal first.coordinates, cached.coordinates
  end

  def test_amazon_location_service_caches_empty_results
    store = configure_fresh_cache

    assert_equal [], Geocoder.search("no results")
    assert_equal 1, store.size
    assert_equal [], Geocoder.search("no results")
  end

  private

  # The lookup singleton memoizes its Cache wrapper, so clear it to make these
  # tests independent of any cache configured by previously-run tests.
  def configure_fresh_cache
    store = {}
    Geocoder.configure(cache: store)
    Geocoder::Lookup.get(:amazon_location_service).instance_variable_set(:@cache, nil)
    store
  end
end
