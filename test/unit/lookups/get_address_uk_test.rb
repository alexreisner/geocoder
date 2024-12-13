# encoding: utf-8
require 'test_helper'

class GetAddressUkTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :get_address_uk)
    set_api_key!(:get_address_uk)
  end

  def test_result_components_with_postcode
    results = Geocoder.search('mk11df')
    assert_equal 1, results.size
    assert_equal '3 Denbigh Road, , , , Bletchley, Milton Keynes, Buckinghamshire', results.first.address
    assert_equal [52.00535583496094, -0.7367798686027527], results.first.coordinates
    assert_equal 'Milton Keynes', results.first.city
  end

  def test_no_results
    assert_equal [], Geocoder.search('no results')
  end

  def test_invalid_key
    Geocoder.configure(always_raise: [Geocoder::InvalidApiKey])

    assert_raises Geocoder::InvalidApiKey do
      Geocoder.search('invalid key')
    end
  end

  def test_invalid_postcode
    Geocoder.configure(always_raise: [Geocoder::InvalidRequest])

    assert_raises Geocoder::InvalidRequest do
      Geocoder.search('invalid postcode')
    end
  end

  def test_over_query_limit
    Geocoder.configure(always_raise: [Geocoder::OverQueryLimitError])

    assert_raises Geocoder::OverQueryLimitError do
      Geocoder.search('over query limit')
    end
  end

  def test_server_error
    Geocoder.configure(always_raise: [Geocoder::ServiceUnavailable])

    assert_raises(Geocoder::ServiceUnavailable) do
      Geocoder.search('server error')
    end
  end
end
