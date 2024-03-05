# encoding: utf-8
require 'test_helper'

class GooglePlacesDetailsNewTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(lookup: :google_places_details_new)
    set_api_key!(:google_places_details_new)
  end

  def test_google_places_details_new_result_components
    assert_equal "Manhattan", madison_square_garden.address_components_of_type(:sublocality).first["longText"]
  end

  def test_google_places_details_new_result_components_contains_route
    assert_equal "Pennsylvania Plaza", madison_square_garden.address_components_of_type(:route).first["longText"]
  end

  def test_google_places_details_new_result_components_contains_street_number
    assert_equal "4", madison_square_garden.address_components_of_type(:street_number).first["longText"]
  end

  def test_google_places_details_new_street_address_returns_formatted_street_address
    assert_equal "4 Pennsylvania Plaza", madison_square_garden.street_address
  end

  def test_google_places_details_new_result_contains_place_id
    assert_equal "ChIJhRwB-yFawokR5Phil-QQ3zM", madison_square_garden.place_id
  end

  def test_google_places_details_new_result_contains_latitude
    assert_equal madison_square_garden.latitude, 40.750504
  end

  def test_google_places_details_new_result_contains_longitude
    assert_equal madison_square_garden.longitude, -73.993439
  end

  def test_google_places_details_new_result_contains_rating
    assert_equal 4.4, madison_square_garden.rating
  end

  def test_google_places_details_new_result_contains_rating_count
    assert_equal 382, madison_square_garden.rating_count
  end

  def test_google_places_details_new_result_contains_reviews
    reviews = madison_square_garden.reviews

    assert_equal 2, reviews.size
    assert_equal "John Smith", reviews.first["authorAttribution"]["displayName"]
    assert_equal 5, reviews.first["rating"]
    assert_equal "It's nice.", reviews.first["text"]["text"]
    assert_equal "en", reviews.first["text"]["languageCode"]
  end

  def test_google_places_details_new_result_contains_types
    assert_equal madison_square_garden.types, %w(tourist_attraction stadium sports_complex event_venue sports_club point_of_interest establishment)
  end

  def test_google_places_details_new_result_contains_primary_type
    assert_equal madison_square_garden.primary_type, "event_venue"
  end

  def test_google_places_details_new_result_contains_website
    assert_equal madison_square_garden.website, "http://www.thegarden.com/"
  end

  def test_google_places_details_new_result_contains_phone_number
    assert_equal madison_square_garden.phone_number, "+1 212-465-6741"
  end

  def test_google_places_details_new_query_url_contains_language
    url = lookup.query_url(Geocoder::Query.new("some-place-id", language: "de"))
    assert_match(/languageCode=de/, url)
  end

  def test_google_places_details_new_query_url_always_uses_https
    url = lookup.query_url(Geocoder::Query.new("some-place-id"))
    assert_match(%r(^https://), url)
  end

  def test_google_places_details_new_query_url_contains_specific_fields_when_given
    fields = %w[formattedAddress id]
    url = lookup.query_url(Geocoder::Query.new("some-place-id", fields: fields))
    assert_match(/fields=#{fields.join('%2C')}/, url)
  end

  def test_google_places_details_new_query_url_contains_specific_fields_when_configured
    fields = %w[businessStatus photos]
    Geocoder.configure(google_places_details_new: {fields: fields})
    url = lookup.query_url(Geocoder::Query.new("some-place-id"))
    assert_match(/fields=#{fields.join('%2C')}/, url)
    Geocoder.configure(google_places_details_new: {})
  end

  def test_google_places_details_new_result_with_invalid_place_id_empty
    silence_warnings do
      assert_equal Geocoder.search("invalid request"), []
    end
  end

  def test_raises_exception_on_google_places_details_invalid_request
    Geocoder.configure(always_raise: [Geocoder::InvalidRequest])
    assert_raises Geocoder::InvalidRequest do
      Geocoder.search("invalid request")
    end
  end

  private

  def lookup
    Geocoder::Lookup::GooglePlacesDetailsNew.new
  end

  def madison_square_garden
    Geocoder.search("ChIJhRwB-yFawokR5Phil-QQ3zM").first
  end

end
