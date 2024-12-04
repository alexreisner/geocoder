require 'test_helper'

class AzureTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(lookup: :azure, azure: { limit: 1 })
    set_api_key!(:azure)
  end

  def test_azure_results_jakarta_properties
    result = Geocoder.search('Jakarta').first

    assert_equal 'Jakarta', result&.city
    assert_equal 'Indonesia', result&.country
    assert_equal 'Jakarta, Jakarta', result&.address
  end

  def test_azure_results_jakarta_coordinates
    result = Geocoder.search('Jakarta').first

    assert_equal -6.17476, result&.coordinates[0]
    assert_equal 106.82707, result&.coordinates[1]
  end

  def test_azure_results_jakarta_viewport
    result = Geocoder.search('Jakarta').first

    assert_equal(
      {
        'topLeftPoint' => {
          'lat' => -5.95462,
          'lon' => 106.68588
        },
        'btmRightPoint'=> {
          'lat' => -6.37083,
          'lon' => 106.9729
        }
      }, result&.viewport
    )
  end

  def test_azure_reverse_results_properties
    result = Geocoder.search([-6.198967624433219, 106.82358133258361]).first

    assert_equal 'Jakarta', result&.city
    assert_equal 'Indonesia', result&.country
    assert_equal 'Jalan Mohammad Husni Thamrin 10, Kecamatan Jakarta, DKI Jakarta 10230', result&.address
  end

  def test_azure_no_result
    result = Geocoder.search('no results')

    assert_equal 0, result&.length
  end

  def test_azure_results_no_street_number
    result = Geocoder.search('Jakarta').first

    assert_equal nil, result&.street_number
  end

  def test_query_url
    query = Geocoder::Query.new('Jakarta')

    assert_equal 'https://atlas.microsoft.com/search/address/json?api-version=1.0&language=en&limit=1&query=Jakarta&subscription-key=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', query.url
  end

  def test_reverse_query_url
    query = Geocoder::Query.new([-6.198967624433219, 106.82358133258361])

    assert_equal "https://atlas.microsoft.com/search/address/reverse/json?api-version=1.0&language=en&limit=1&query=-6.198967624433219%2C106.82358133258361&subscription-key=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", query.url
  end

  def test_azure_query_url_contains_api_key
    lookup  = Geocoder::Lookup::Azure.new
    url     = lookup.query_url(
                Geocoder::Query.new(
                  'Test Query'
                )
              )

    assert_match(/subscription-key=a+/, url)
  end

  def test_azure_query_url_contains_language
    lookup = Geocoder::Lookup::Azure.new
    url = lookup.query_url(
      Geocoder::Query.new(
        'Test Query',
        language: 'en'
      )
    )

    assert_match(/language=en/, url)
  end

  def test_azure_query_url_contains_text
    lookup  = Geocoder::Lookup::Azure.new
    url     = lookup.query_url(
      Geocoder::Query.new(
        'PT Kulkul Teknologi Internasional'
      )
    )

    assert_match(/PT\+Kulkul\+Teknologi\+Internasional/i, url)
  end

  def test_azure_reverse_query_url_contains_lat_lon
    lookup  = Geocoder::Lookup::Azure.new
    url     = lookup.query_url(
                Geocoder::Query.new(
                  [-6.198967624433219, 106.82358133258361]
                )
              )

    assert_match(/query=-6\.198967624433219%2C106\.82358133258361/, url)
  end

  def test_azure_invalid_key
    result = Geocoder.search('invalid key').first

    assert_equal 'InvalidKey', result&.data&.last['code']
    assert_equal 'The provided key was incorrect or the account resource does not exist.', result&.data&.last['message']
  end
end