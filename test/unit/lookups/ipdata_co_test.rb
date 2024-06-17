# encoding: utf-8
require 'test_helper'

class IpdataCoTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(ip_lookup: :ipdata_co)
  end

  def test_result_on_ip_address_search
    result = Geocoder.search("74.200.247.59").first
    assert result.is_a?(Geocoder::Result::IpdataCo)
  end

  def test_result_on_loopback_ip_address_search
    result = Geocoder.search("127.0.0.1").first
    assert_equal "127.0.0.1", result.ip
    assert_equal 'RD',        result.country_code
    assert_equal "Reserved",  result.country
  end

  def test_result_on_private_ip_address_search
    result = Geocoder.search("172.19.0.1").first
    assert_equal "172.19.0.1", result.ip
    assert_equal 'RD',         result.country_code
    assert_equal "Reserved",   result.country
  end

  def test_invalid_json
    Geocoder.configure(:always_raise => [Geocoder::ResponseParseError])
    assert_raise Geocoder::ResponseParseError do
      Geocoder.search("8.8.8", ip_address: true)
    end
  end

  def test_result_components
    result = Geocoder.search("74.200.247.59").first
    assert_equal "Jersey City, NJ 07302, United States", result.address
  end

  def test_not_authorized
    Geocoder.configure(always_raise: [Geocoder::RequestDenied])
    lookup = Geocoder::Lookup.get(:ipdata_co)
      assert_raises Geocoder::RequestDenied do
        response = MockHttpResponse.new(code: 403)
        lookup.send(:check_response_for_errors!, response)
    end
  end

  def test_api_key
    Geocoder.configure(:api_key => 'XXXX')

    # HACK: run the code once to add the api key to the HTTP request headers
    Geocoder.search('8.8.8.8')
    # It's really hard to 'un-monkey-patch' the base lookup class here

    require 'webmock/test_unit'
    WebMock.enable!
    stubbed_request = WebMock.stub_request(:get, "https://api.ipdata.co/8.8.8.8?api-key=XXXX").to_return(status: 200)

    g = Geocoder::Lookup::IpdataCo.new
    g.send(:actual_make_api_request, Geocoder::Query.new('8.8.8.8'))
    assert_requested(stubbed_request)

    WebMock.reset!
    WebMock.disable!
  end
end
