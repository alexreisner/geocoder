# encoding: utf-8
require 'test_helper'

class GooglePlacesSearchTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :google_places_search)
    set_api_key!(:google_places_search)
  end

  def test_google_places_search_result_contains_place_id
    assert_equal "ChIJhRwB-yFawokR5Phil-QQ3zM", madison_square_garden.place_id
  end

  def test_google_places_search_result_contains_latitude
    assert_equal madison_square_garden.latitude, 40.75050450000001
  end

  def test_google_places_search_result_contains_longitude
    assert_equal madison_square_garden.longitude, -73.9934387
  end

  def test_google_places_search_result_contains_rating
    assert_equal 4.5, madison_square_garden.rating
  end

  def test_google_places_search_result_contains_types
    assert_equal madison_square_garden.types, %w(stadium point_of_interest establishment)
  end

  def test_google_places_search_query_url_contains_language
    url = lookup.query_url(Geocoder::Query.new("some-address", language: "de"))
    assert_match(/language=de/, url)
  end

  def test_google_places_search_query_url_contains_input
    url = lookup.query_url(Geocoder::Query.new("some-address"))
    assert_match(/input=some-address/, url)
  end

  def test_google_places_search_query_url_contains_input_typer
    url = lookup.query_url(Geocoder::Query.new("some-address"))
    assert_match(/inputtype=textquery/, url)
  end

  def test_google_places_search_query_url_always_uses_https
    url = lookup.query_url(Geocoder::Query.new("some-address"))
    assert_match(%r{^https://}, url)
  end

  def test_google_places_search_query_url_contains_every_field_available_by_default
    url = lookup.query_url(Geocoder::Query.new("some-address"))
    fields = %w[id reference business_status formatted_address geometry icon name 
      photos place_id plus_code types opening_hours price_level rating 
      user_ratings_total]
    assert_match(/fields=#{fields.join('%2C')}/, url)
  end

  def test_google_places_search_query_url_contains_specific_fields_when_given
    fields = %w[formatted_address place_id]
    url = lookup.query_url(Geocoder::Query.new("some-address", fields: fields))
    
    assert_match(/fields=#{fields.join('%2C')}/, url)
  end

  def test_google_places_search_query_url_uses_find_place_service
    url = lookup.query_url(Geocoder::Query.new("some-address"))
    assert_match(%r{//maps.googleapis.com/maps/api/place/findplacefromtext/}, url)
  end

  private

  def lookup
    Geocoder::Lookup::GooglePlacesSearch.new
  end

  def madison_square_garden
    Geocoder.search("Madison Square Garden").first
  end
end
