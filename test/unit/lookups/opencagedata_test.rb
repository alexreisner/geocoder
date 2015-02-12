# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class OpencagedataTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :opencagedata)
    set_api_key!(:opencagedata)
  end

  def test_result_components
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "West 31st Street", result.street
    assert_match /46, West 31st Street, Koreatown, New York County, 10011, New York City, New York, United States of America/, result.address

  end

  def test_opencagedata_query_url_contains_bounds
    lookup = Geocoder::Lookup::Opencagedata.new
    url = lookup.query_url(Geocoder::Query.new(
      "Some street",
      :bounds => [[40.0, -120.0], [39.0, -121.0]]
    ))
    assert_match(/bounds=40.0+%2C-120.0+%2C39.0+%2C-121.0+/, url)
  end


  def test_no_results
    results = Geocoder.search("no results")
    assert_equal 0, results.length
  end


  def test_opencagedata_reverse_url
    query = Geocoder::Query.new([45.423733, -75.676333])
    assert_match /\bq=45.423733%2C-75.676333\b/, query.url
  end



  def test_raises_exception_when_invalid_request
    Geocoder.configure(always_raise: [Geocoder::InvalidRequest])
    assert_raises Geocoder::InvalidRequest do
      Geocoder.search("invalid request")
    end
  end

  def test_raises_exception_when_invalid_api_key
    Geocoder.configure(always_raise: [Geocoder::InvalidApiKey])
    assert_raises Geocoder::InvalidApiKey do
      Geocoder.search("invalid api key")
    end
  end


  def test_raises_exception_when_over_query_limit
    Geocoder.configure(:always_raise => [Geocoder::OverQueryLimitError])
    l = Geocoder::Lookup.get(:opencagedata)
    assert_raises Geocoder::OverQueryLimitError do
      l.send(:results, Geocoder::Query.new("over limit"))
    end
  end
end
