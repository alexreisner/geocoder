# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class YahooTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :yahoo)
    set_api_key!(:yahoo)
  end

  def test_no_results
    assert_equal [], Geocoder.search("no results")
  end

  def test_error
    silence_warnings do
      assert_equal [], Geocoder.search("error")
    end
  end

  def test_result_components
    result = Geocoder.search("madison square garden").first
    assert_equal "10001", result.postal_code
    assert_equal "Madison Square Garden, New York, NY 10001, United States", result.address
  end

  def test_raises_exception_when_over_query_limit
    Geocoder.configure(:always_raise => [Geocoder::OverQueryLimitError])
    l = Geocoder::Lookup.get(:yahoo)
    assert_raises Geocoder::OverQueryLimitError do
      l.send(:results, Geocoder::Query.new("over limit"))
    end
  end
end
