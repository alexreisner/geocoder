# encoding: utf-8
require 'test_helper'

class InputHandlingTest < Test::Unit::TestCase

  def test_ip_address_detection
    assert Geocoder.send(:ip_address?, "232.65.123.94")
    assert Geocoder.send(:ip_address?, "666.65.123.94") # technically invalid
    assert !Geocoder.send(:ip_address?, "232.65.123.94.43")
    assert !Geocoder.send(:ip_address?, "232.65.123")
  end

  def test_blank_query_detection
    assert Geocoder.send(:blank_query?, nil)
    assert Geocoder.send(:blank_query?, "")
    assert Geocoder.send(:blank_query?, "\t  ")
    assert !Geocoder.send(:blank_query?, "a")
    assert !Geocoder.send(:blank_query?, "Москва") # no ASCII characters
  end

  def test_coordinates_detection
    lookup = Geocoder::Lookup::Google.new
    assert lookup.send(:coordinates?, "51.178844,5")
    assert lookup.send(:coordinates?, "51.178844, -1.826189")
    assert !lookup.send(:coordinates?, "232.65.123")
  end

  def test_does_not_choke_on_nil_address
    all_lookups.each do |l|
      Geocoder::Configuration.lookup = l
      assert_nothing_raised { Venue.new("Venue", nil).geocode }
    end
  end

  def test_extract_coordinates
    coords = [-23,47]
    l = Landmark.new("Madagascar", coords[0], coords[1])
    assert_equal coords, Geocoder::Calculations.extract_coordinates(l)
    assert_equal coords, Geocoder::Calculations.extract_coordinates(coords)
  end
end
