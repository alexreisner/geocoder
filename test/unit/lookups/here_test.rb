# encoding: utf-8
require 'test_helper'

class HereTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(lookup: :here)
    set_api_key!(:here)
  end

  def test_with_array_api_key_raises_when_configured
    Geocoder.configure(api_key: %w[foo bar])
    Geocoder.configure(always_raise: :all)
    assert_raises(Geocoder::ConfigurationError) { Geocoder.search('berlin').first }
  end

  def test_here_viewport
    result = Geocoder.search('berlin').first
    assert_equal [52.33812, 13.08835, 52.6755, 13.761], result.viewport
  end

  def test_here_no_viewport
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal [], result.viewport
  end

  def test_here_query_url_for_reverse_geocoding
    lookup = Geocoder::Lookup::Here.new
    url = lookup.query_url(
      Geocoder::Query.new(
        "42.42,21.21"
      )
    )

    expected = /revgeocode\.search\.hereapi\.com\/v1\/revgeocode.+at=42\.42%2C21\.21/

    assert_match(expected, url)
  end

  def test_here_query_url_for_geocode
    lookup = Geocoder::Lookup::Here.new
    url = lookup.query_url(
      Geocoder::Query.new(
        "Madison Square Garden, New York, NY"
      )
    )

    expected = /geocode\.search\.hereapi\.com\/v1\/geocode.+q=Madison\+Square\+Garden%2C\+New\+York%2C\+NY/

    assert_match(expected, url)
  end

  def test_here_query_url_contains_country
    lookup = Geocoder::Lookup::Here.new
    url = lookup.query_url(
      Geocoder::Query.new(
        'Some Intersection',
        country: 'GBR'
      )
    )
    assert_match(/in=countryCode%3AGBR/, url)
  end

  def test_here_query_url_contains_api_key
    lookup = Geocoder::Lookup::Here.new
    url = lookup.query_url(
      Geocoder::Query.new(
        'Some Intersection'
      )
    )
    assert_match(/apiKey=+/, url)
  end
end
