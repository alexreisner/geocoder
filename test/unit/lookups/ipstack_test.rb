# encoding: utf-8
require 'test_helper'

class SpyLogger
  def initialize
    @log = []
  end

  def logged?(msg)
    @log.include?(msg)
  end

  def add(level, msg)
    @log << msg
  end
end

class IpstackTest < GeocoderTestCase

  def setup
    @logger = SpyLogger.new
    Geocoder::Configuration.instance.data.clear
    Geocoder::Configuration.set_defaults
    Geocoder.configure(
      :api_key => '123',
      :ip_lookup => :ipstack,
      :always_raise => :all,
      :logger => @logger
    )
  end

  def test_result_on_ip_address_search
    result = Geocoder.search("134.201.250.155").first
    assert result.is_a?(Geocoder::Result::Ipstack)
  end

  def test_result_components
    result = Geocoder.search("134.201.250.155").first
    assert_equal "Los Angeles, CA 90013, United States", result.address
  end

  def test_all_top_level_api_fields
    result = Geocoder.search("134.201.250.155").first
    assert_equal "134.201.250.155", result.ip
    assert_equal "134.201.250.155", result.hostname
    assert_equal "NA",              result.continent_code
    assert_equal "North America",   result.continent_name
    assert_equal "US",              result.country_code
    assert_equal "United States",   result.country_name
    assert_equal "CA",              result.region_code
    assert_equal "California",      result.region_name
    assert_equal "Los Angeles",     result.city
    assert_equal "90013",           result.zip
    assert_equal 34.0453,           result.latitude
    assert_equal (-118.2413),       result.longitude
  end

  def test_nested_api_fields
    result = Geocoder.search("134.201.250.155").first

    assert result.location.is_a?(Hash)
    assert_equal 5368361, result.location['geoname_id']

    assert result.time_zone.is_a?(Hash)
    assert_equal "America/Los_Angeles", result.time_zone['id']

    assert result.currency.is_a?(Hash)
    assert_equal "USD", result.currency['code']

    assert result.connection.is_a?(Hash)
    assert_equal 25876, result.connection['asn']

    assert result.security.is_a?(Hash)
  end

  def test_required_base_fields
    result = Geocoder.search("134.201.250.155").first
    assert_equal "California",      result.state
    assert_equal "CA",              result.state_code
    assert_equal "United States",   result.country
    assert_equal "90013",           result.postal_code
    assert_equal [34.0453, -118.2413], result.coordinates
  end

  def test_logs_deprecation_of_metro_code_field
    result = Geocoder.search("134.201.250.155").first
    result.metro_code

    assert @logger.logged?("Ipstack does not implement `metro_code` in api results.  Please discontinue use.")
  end

  def test_localhost_loopback
    result = Geocoder.search("127.0.0.1").first
    assert_equal "127.0.0.1", result.ip
    assert_equal "RD",        result.country_code
    assert_equal "Reserved",  result.country_name
  end

  def test_localhost_loopback_defaults
    result = Geocoder.search("127.0.0.1").first
    assert_equal "127.0.0.1", result.ip
    assert_equal "",          result.hostname
    assert_equal "",          result.continent_code
    assert_equal "",          result.continent_name
    assert_equal "RD",        result.country_code
    assert_equal "Reserved",  result.country_name
    assert_equal "",          result.region_code
    assert_equal "",          result.region_name
    assert_equal "",          result.city
    assert_equal "",          result.zip
    assert_equal 0,           result.latitude
    assert_equal 0,           result.longitude
    assert_equal({},          result.location)
    assert_equal({},          result.time_zone)
    assert_equal({},          result.currency)
    assert_equal({},          result.connection)
  end

  def test_localhost_private
    result = Geocoder.search("172.19.0.1").first
    assert_equal "172.19.0.1", result.ip
    assert_equal "RD",         result.country_code
    assert_equal "Reserved",   result.country_name
  end

  def test_api_request_adds_access_key
    lookup = Geocoder::Lookup.get(:ipstack)
    assert_match 'http://api.ipstack.com/74.200.247.59?access_key=123', lookup.query_url(Geocoder::Query.new("74.200.247.59"))
  end

  def test_api_request_adds_security_when_specified
    lookup = Geocoder::Lookup.get(:ipstack)

    query_url = lookup.query_url(Geocoder::Query.new("74.200.247.59", params: { security: '1' }))

    assert_match(/&security=1/, query_url)
  end

  def test_api_request_adds_hostname_when_specified
    lookup = Geocoder::Lookup.get(:ipstack)

    query_url = lookup.query_url(Geocoder::Query.new("74.200.247.59", params: { hostname: '1' }))

    assert_match(/&hostname=1/, query_url)
  end

  def test_api_request_adds_language_when_specified
    lookup = Geocoder::Lookup.get(:ipstack)

    query_url = lookup.query_url(Geocoder::Query.new("74.200.247.59", params: { language: 'es' }))

    assert_match(/&language=es/, query_url)
  end

  def test_api_request_adds_fields_when_specified
    lookup = Geocoder::Lookup.get(:ipstack)

    query_url = lookup.query_url(Geocoder::Query.new("74.200.247.59", params: { fields: 'foo,bar' }))

    assert_match(/&fields=foo%2Cbar/, query_url)
  end

  def test_logs_warning_when_errors_are_set_not_to_raise
    Geocoder::Configuration.instance.data.clear
    Geocoder::Configuration.set_defaults
    Geocoder.configure(api_key: '123', ip_lookup: :ipstack, logger: @logger)

    lookup = Geocoder::Lookup.get(:ipstack)

    lookup.send(:results, Geocoder::Query.new("not_found"))

    assert @logger.logged?("Ipstack Geocoding API error: The requested resource does not exist.")
  end

  def test_uses_lookup_specific_configuration
    Geocoder::Configuration.instance.data.clear
    Geocoder::Configuration.set_defaults
    Geocoder.configure(api_key: '123', ip_lookup: :ipstack, logger: @logger, ipstack: { api_key: '345'})

    lookup = Geocoder::Lookup.get(:ipstack)
    assert_match 'http://api.ipstack.com/74.200.247.59?access_key=345', lookup.query_url(Geocoder::Query.new("74.200.247.59"))
  end

  def test_not_authorized   lookup = Geocoder::Lookup.get(:ipstack)

    error = assert_raise Geocoder::InvalidRequest do
      lookup.send(:results, Geocoder::Query.new("not_found"))
    end

    assert_equal error.message, "The requested resource does not exist."
  end

  def test_missing_access_key
    lookup = Geocoder::Lookup.get(:ipstack)

    error = assert_raise Geocoder::InvalidApiKey do
      lookup.send(:results, Geocoder::Query.new("missing_access_key"))
    end

    assert_equal error.message, "No API Key was specified."
  end

  def test_invalid_access_key
    lookup = Geocoder::Lookup.get(:ipstack)

    error = assert_raise Geocoder::InvalidApiKey do
      lookup.send(:results, Geocoder::Query.new("invalid_access_key"))
    end

    assert_equal error.message, "No API Key was specified or an invalid API Key was specified."
  end

  def test_inactive_user
    lookup = Geocoder::Lookup.get(:ipstack)

    error = assert_raise Geocoder::Error do
      lookup.send(:results, Geocoder::Query.new("inactive_user"))
    end

    assert_equal error.message, "The current user account is not active. User will be prompted to get in touch with Customer Support."
  end

  def test_invalid_api_function
    lookup = Geocoder::Lookup.get(:ipstack)

    error = assert_raise Geocoder::InvalidRequest do
      lookup.send(:results, Geocoder::Query.new("invalid_api_function"))
    end

    assert_equal error.message, "The requested API endpoint does not exist."
  end

  def test_usage_limit
    lookup = Geocoder::Lookup.get(:ipstack)

    error = assert_raise Geocoder::OverQueryLimitError do
      lookup.send(:results, Geocoder::Query.new("usage_limit"))
    end

    assert_equal error.message, "The maximum allowed amount of monthly API requests has been reached."
  end

  def test_access_restricted
    lookup = Geocoder::Lookup.get(:ipstack)

    error = assert_raise Geocoder::RequestDenied do
      lookup.send(:results, Geocoder::Query.new("access_restricted"))
    end

    assert_equal error.message, "The current subscription plan does not support this API endpoint."
  end

  def test_protocol_access_restricted
    lookup = Geocoder::Lookup.get(:ipstack)

    error = assert_raise Geocoder::RequestDenied do
      lookup.send(:results, Geocoder::Query.new("protocol_access_restricted"))
    end

    assert_equal error.message, "The user's current subscription plan does not support HTTPS Encryption."
  end

  def test_invalid_fields
    lookup = Geocoder::Lookup.get(:ipstack)

    error = assert_raise Geocoder::InvalidRequest do
      lookup.send(:results, Geocoder::Query.new("invalid_fields"))
    end

    assert_equal error.message, "One or more invalid fields were specified using the fields parameter."
  end

  def test_too_many_ips
    lookup = Geocoder::Lookup.get(:ipstack)

    error = assert_raise Geocoder::InvalidRequest do
      lookup.send(:results, Geocoder::Query.new("too_many_ips"))
    end

    assert_equal error.message, "Too many IPs have been specified for the Bulk Lookup Endpoint. (max. 50)"
  end

  def test_batch_not_supported
    lookup = Geocoder::Lookup.get(:ipstack)

    error = assert_raise Geocoder::RequestDenied do
      lookup.send(:results, Geocoder::Query.new("batch_not_supported"))
    end

    assert_equal error.message, "The Bulk Lookup Endpoint is not supported on the current subscription plan"
  end
end
