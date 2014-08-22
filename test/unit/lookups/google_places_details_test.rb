# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class GooglePlacesDetailsTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :google_places_details)
    set_api_key!(:google_places_details)
  end

  def test_google_places_details_result_components
    assert_equal "Manhattan", madison_square_garden.address_components_of_type(:sublocality).first["long_name"]
  end

  def test_google_places_details_result_components_contains_route
    assert_equal "Pennsylvania Plaza", madison_square_garden.address_components_of_type(:route).first["long_name"]
  end

  def test_google_places_details_result_components_contains_street_number
    assert_equal "4", madison_square_garden.address_components_of_type(:street_number).first["long_name"]
  end

  def test_google_places_details_street_address_returns_formatted_street_address
    assert_equal "4 Pennsylvania Plaza", madison_square_garden.street_address
  end

  def test_google_places_details_result_contains_place_id
    assert_equal "ChIJhRwB-yFawokR5Phil-QQ3zM", madison_square_garden.place_id
  end

  def test_google_places_details_result_contains_latitude
    assert_equal madison_square_garden.latitude, 40.750504
  end

  def test_google_places_details_result_contains_longitude
    assert_equal madison_square_garden.longitude, -73.993439
  end

  def test_google_places_details_result_contains_rating
    assert_equal 4.4, madison_square_garden.rating
  end

  def test_google_places_details_result_contains_rating_count
    assert_equal 382, madison_square_garden.rating_count
  end

  def test_google_places_details_result_contains_reviews
    reviews = madison_square_garden.reviews

    assert_equal 2, reviews.size
    assert_equal "John Smith", reviews.first["author_name"]
    assert_equal 5, reviews.first["rating"]
    assert_equal "It's nice.", reviews.first["text"]
    assert_equal "en", reviews.first["language"]
  end

  def test_google_places_details_result_contains_types
    assert_equal madison_square_garden.types, %w(stadium establishment)
  end

  def test_google_places_details_result_contains_website
    assert_equal madison_square_garden.website, "http://www.thegarden.com/"
  end

  def test_google_places_details_result_contains_phone_number
    assert_equal madison_square_garden.phone_number, "+1 212-465-6741"
  end

  def test_google_places_details_query_url_contains_placeid
    url = lookup.query_url(Geocoder::Query.new("some-place-id"))
    assert_match(/placeid=some-place-id/, url)
  end

  def test_google_places_details_query_url_contains_language
    url = lookup.query_url(Geocoder::Query.new("some-place-id", language: "de"))
    assert_match(/language=de/, url)
  end

  def test_google_places_details_query_url_always_uses_https
    url = lookup.query_url(Geocoder::Query.new("some-place-id"))
    assert_match(%r(^https://), url)
  end

  def test_google_places_details_result_with_no_reviews_shows_empty_reviews
    assert_equal no_reviews_result.reviews, []
  end

  def test_google_places_details_result_with_no_types_shows_empty_types
    assert_equal no_types_result.types, []
  end

  def test_google_places_details_result_with_invalid_place_id_empty
    assert_equal Geocoder.search("invalid request"), []
  end

  def test_raises_exception_on_google_places_details_invalid_request
    Geocoder.configure(always_raise: [Geocoder::InvalidRequest])
    assert_raises Geocoder::InvalidRequest do
      Geocoder.search("invalid request")
    end
  end

  private

  def lookup
    Geocoder::Lookup::GooglePlacesDetails.new
  end

  def madison_square_garden
    Geocoder.search("ChIJhRwB-yFawokR5Phil-QQ3zM").first
  end

  def no_reviews_result
    Geocoder.search("no reviews").first
  end

  def no_types_result
    Geocoder.search("no types").first
  end

end
