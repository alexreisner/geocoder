# encoding: utf-8

require 'test_helper'

class EmptyTest < GeocoderTestCase
  def setup
    Geocoder.configure(lookup: :empty)
  end

  def test_results_empty
    assert_empty Geocoder.search('anything')
  end
end
