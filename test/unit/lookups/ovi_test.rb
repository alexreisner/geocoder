# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class OviTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :ovi)
  end

  def test_ovi_viewport
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal [40.7493451, -73.9948616, 40.7515934, -73.9918938],
      result.viewport
  end

end
