# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..")
require 'test_helper'

class TestModeTest < GeocoderTestCase

  def setup
    @_original_lookup = Geocoder.config.lookup
    Geocoder.configure(:lookup => :test)
  end

  def teardown
    Geocoder::Lookup::Test.reset
    Geocoder.configure(:lookup => @_original_lookup)
  end

  def test_search_with_known_stub
    Geocoder::Lookup::Test.add_stub("New York, NY", [mock_attributes])

    results = Geocoder.search("New York, NY")
    result = results.first

    assert_equal 1, results.size
    mock_attributes.keys.each do |attr|
      assert_equal mock_attributes[attr], result.send(attr)
    end
  end

  def test_search_with_unknown_stub_without_default
    assert_raise ArgumentError do
      Geocoder.search("New York, NY")
    end
  end

  def test_search_with_unknown_stub_with_default
    Geocoder::Lookup::Test.set_default_stub([mock_attributes])

    results = Geocoder.search("Atlantis, OC")
    result = results.first

    assert_equal 1, results.size
    mock_attributes.keys.each do |attr|
      assert_equal mock_attributes[attr], result.send(attr)
    end
  end

  def test_search_with_custom_attributes
    custom_attributes = mock_attributes.merge(:custom => 'NY, NY')
    Geocoder::Lookup::Test.add_stub("New York, NY", [custom_attributes])

    result = Geocoder.search("New York, NY").first

    assert_equal 'NY, NY', result.custom
  end

  private
  def mock_attributes
    coordinates = [40.7143528, -74.0059731]
    @mock_attributes ||= {
      'coordinates'  => coordinates,
      'latitude'     => coordinates[0],
      'longitude'    => coordinates[1],
      'address'      => 'New York, NY, USA',
      'state'        => 'New York',
      'state_code'   => 'NY',
      'country'      => 'United States',
      'country_code' => 'US',
    }
  end
end
