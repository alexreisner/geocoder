require 'test_helper'

class PickpointTest < GeocoderTestCase
  def setup
    Geocoder.configure(lookup: :pickpoint)
    set_api_key!(:pickpoint)
  end

  def test_result_components
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "10001", result.postal_code
    assert_equal "Madison Square Garden, West 31st Street, Long Island City, New York City, New York, 10001, United States of America", result.address
  end

  def test_result_viewport
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal [40.749828338623, -73.9943389892578, 40.7511596679688, -73.9926528930664],
                 result.viewport
  end

  def test_url_contains_api_key
    Geocoder.configure(pickpoint: {api_key: "pickpoint-api-key"})
    query = Geocoder::Query.new("Leadville, CO")
    assert_equal "https://api.pickpoint.io/v1/forward?key=pickpoint-api-key&accept-language=en&addressdetails=1&format=json&q=Leadville%2C+CO", query.url
  end

  def test_raises_exception_with_invalid_api_key
    Geocoder.configure(always_raise: [Geocoder::InvalidApiKey])
    assert_raises Geocoder::InvalidApiKey do
      Geocoder.search("invalid api key")
    end
  end
end
