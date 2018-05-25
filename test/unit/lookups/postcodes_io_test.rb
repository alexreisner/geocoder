# encoding: utf-8
require 'test_helper'

class PostcodesIoTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :postcodes_io)
  end

  def test_result_on_postcode_search
    results = Geocoder.search('WR26NJ')

    assert_equal 1, results.size
    assert_equal 'Worcestershire', results.first.county
    assert_equal [52.2327158260535, -2.26972239639173], results.first.coordinates
  end

  def test_no_results
    assert_equal [], Geocoder.search('no results')
  end
end
