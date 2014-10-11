# encoding: utf-8
$: << File.join(File.dirname(__FILE__), '..', '..')
require 'test_helper'

class PostcodeAnywhereUkTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :postcode_anywhere_uk)
    set_api_key!(:postcode_anywhere_uk)
  end

  def test_result_components_with_placename_search
    results = Geocoder.search('Romsey')

    assert_equal 1, results.size
    assert_equal 'Romsey, Hampshire', results.first.address
    assert_equal 'SU 35270 21182', results.first.os_grid
    assert_equal [50.9889, -1.4989], results.first.coordinates
    assert_equal 'Romsey', results.first.city
  end

  def test_result_components_with_postcode
    results = Geocoder.search('WR26NJ')

    assert_equal 1, results.size
    assert_equal 'Moseley Road, Hallow, Worcester', results.first.address
    assert_equal 'SO 81676 59425', results.first.os_grid
    assert_equal [52.2327, -2.2697], results.first.coordinates
    assert_equal 'Hallow', results.first.city
  end

  def test_result_components_with_county
    results = Geocoder.search('hampshire')

    assert_equal 1, results.size
    assert_equal 'Hampshire', results.first.address
    assert_equal 'SU 48701 26642', results.first.os_grid
    assert_equal [51.037, -1.3068], results.first.coordinates
    assert_equal '', results.first.city
  end

  def test_no_results
    assert_equal [], Geocoder.search('no results')
  end

  def test_key_limit_exceeded_error
    Geocoder.configure(always_raise: [Geocoder::OverQueryLimitError])

    assert_raises Geocoder::OverQueryLimitError do
      Geocoder.search('key limit exceeded')
    end
  end

  def test_unknown_key_error
    Geocoder.configure(always_raise: [Geocoder::InvalidApiKey])

    assert_raises Geocoder::InvalidApiKey do
      Geocoder.search('unknown key')
    end
  end

  def test_generic_error
    Geocoder.configure(always_raise: [Geocoder::Error])

    exception = assert_raises(Geocoder::Error) do
      Geocoder.search('generic error')
    end
    assert_equal 'A generic error occured.', exception.message
  end
end
