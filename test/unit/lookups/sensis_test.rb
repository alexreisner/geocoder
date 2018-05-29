require 'test_helper'

class SensisTest < GeocoderTestCase
  def setup
    Geocoder.configure(lookup: :sensis,
                       api_key: ['sensis_api_token', 'sensis_api_password'],
                       use_post: true)
    Geocoder.configure(sensis: {type: 'unstructured'})
    set_api_key!(:sensis)
  end

  def test_post_request
    lookup = Geocoder::Lookup::Sensis.new
    query = Geocoder::Query.new('test location')
    uri = URI.parse(lookup.query_url(query))
    request = lookup.send(:create_http_request, uri.request_uri, query)

    assert_equal "POST", request.method
  end

  def test_actual_make_api_request_with_https
    lookup = Geocoder::Lookup::Sensis.new
    query = Geocoder::Query.new('test location')
    uri = URI.parse(lookup.query_url(query))
    lookup.send(:create_http_request, uri.request_uri, query)

    assert_equal "https", uri.scheme
  end

  def test_actual_make_api_request_with_correct_header
    headers = {
        'Content-Type': 'application/json',
        'X-Auth-Token': 'api_token',
        'X-Auth-Password': 'api_password'
    }

    Geocoder.configure(sensis: {http_headers: headers, type: 'unstructured'})

    require 'webmock/test_unit'
    WebMock.enable!
    stubbed_request = WebMock.stub_request(:post, "https://api-ems-stage.ext.sensis.com.au/v2/service/geocode/unstructured").
        with(headers: headers).to_return(status: 200)

    g = Geocoder::Lookup::Sensis.new
    g.send(:actual_make_api_request, Geocoder::Query.new('test location'))
    assert_requested(stubbed_request)

    WebMock.reset!
    WebMock.disable!
  end

  def test_sensis_query_url_contains_lookup_type
    Geocoder.configure(lookup: :sensis, :sensis=>{type: 'unstructured'})
    lookup = Geocoder::Lookup::Sensis.new
    url = lookup.query_url(Geocoder::Query.new("Some Intersection"))
    assert_equal 'https://api-ems-stage.ext.sensis.com.au/v2/service/geocode/unstructured', url
  end

  def test_invalid_api_key
    Geocoder.configure(
        sensis: {
            http_headers: {
                'Content-Type': 'application/json',
                'X-Auth-Password': 'api_password'
            },
            type: 'unstructured',
            always_raise: [Geocoder::RequestDenied]
        }
    )

    assert_raises Geocoder::RequestDenied do
      Geocoder.search("invalid api key")
    end
  end

  def test_invalid_request
    Geocoder.configure(
        sensis: {
            type: 'unstructured',
            always_raise: [Geocoder::InvalidRequest]
        }
    )
    assert_raises Geocoder::InvalidRequest do
      Geocoder.search("bad request")
    end
  end

  def test_no_results
    results = Geocoder.search("no results")
    assert_equal [], results
  end

  def test_return_geocode_from_sensis
    coords = Geocoder.coordinates('12 Powlett Street, East Melbourne')
    assert_equal coords, [-37.815951, 144.985673]
  end
end