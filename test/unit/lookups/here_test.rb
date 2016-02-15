# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..", "..")
require 'test_helper'

class HereTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :here)
    set_api_key!(:here)
  end

  def test_here_viewport
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal [40.7493451, -73.9948616, 40.7515934, -73.9918938],
      result.viewport
  end

end
