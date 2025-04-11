# encoding: utf-8
require 'test_helper'

class GooglePlacesApiTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(use_new_places_api: false, lookup: :google_places_details)
  end

  def test_google_places_details_legacy_result_components
    Geocoder.configure(lookup: :google_places_details)
    result = Geocoder.search("PLACE_ID").first
    assert_equal "PLACE_NAME", result.name
    assert_equal "PLACE_FORMATTED_ADDRESS", result.formatted_address
    assert_equal "PLACE_ID", result.place_id
  end

  def test_google_places_search_legacy_result_components
    Geocoder.configure(lookup: :google_places_search)
    result = Geocoder.search("PLACE_QUERY").first
    assert_equal "PLACE_NAME", result.name
    assert_equal "PLACE_FORMATTED_ADDRESS", result.formatted_address
    assert_equal "PLACE_ID", result.place_id
  end

  def test_google_places_details_new_api_result_components
    Geocoder.configure(lookup: :google_places_details, use_new_places_api: true)
    result = Geocoder.search("PLACE_ID").first
    assert_equal "PLACE_NAME", result.display_name
    assert_equal "PLACE_FORMATTED_ADDRESS", result.formatted_address
    assert_equal "PLACE_ID", result.place_id
  end

  def test_google_places_search_new_api_result_components
    Geocoder.configure(lookup: :google_places_search, use_new_places_api: true)
    result = Geocoder.search("PLACE_QUERY").first
    assert_equal "PLACE_NAME", result.display_name
    assert_equal "PLACE_FORMATTED_ADDRESS", result.formatted_address
    assert_equal "PLACE_ID", result.place_id
  end

  def test_location_coordinates_legacy_format
    Geocoder.configure(lookup: :google_places_details)
    result = Geocoder.search("PLACE_ID").first
    assert_equal [40.7484, -73.9857], result.coordinates
  end

  def test_location_coordinates_new_format
    Geocoder.configure(lookup: :google_places_details, use_new_places_api: true)
    result = Geocoder.search("PLACE_ID").first
    assert_equal [40.7484, -73.9857], result.coordinates
  end

  def teardown
    Geocoder.configure(use_new_places_api: false)
  end

  private

  def mock_legacy_api_response
    # Mock response for legacy API
    {
      "place_id" => "PLACE_ID",
      "name" => "PLACE_NAME",
      "formatted_address" => "PLACE_FORMATTED_ADDRESS",
      "geometry" => {
        "location" => {
          "lat" => 40.7484,
          "lng" => -73.9857
        }
      }
    }
  end

  def mock_new_api_response
    # Mock response for new API
    {
      "id" => "PLACE_ID",
      "displayName" => {"text" => "PLACE_NAME"},
      "formattedAddress" => "PLACE_FORMATTED_ADDRESS",
      "location" => {
        "latitude" => 40.7484,
        "longitude" => -73.9857
      }
    }
  end
end
