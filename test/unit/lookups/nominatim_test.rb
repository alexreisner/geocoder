# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class NominatimTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :nominatim)
    set_api_key!(:nominatim)
  end

  def test_result_components
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "10001", result.postal_code
    assert_equal "Madison Square Garden, West 31st Street, Long Island City, New York City, New York, 10001, United States of America", result.address
  end

  def test_host_configuration
    Geocoder.configure(nominatim: {host: "local.com"})
    query = Geocoder::Query.new("Bluffton, SC")
    assert_match %r(http://local\.com), query.url
  end

  def test_raises_exception_when_over_query_limit
    Geocoder.configure(:always_raise => [Geocoder::OverQueryLimitError])
    l = Geocoder::Lookup.get(:nominatim)
    assert_raises Geocoder::OverQueryLimitError do
      l.send(:results, Geocoder::Query.new("over limit"))
    end
  end
end
