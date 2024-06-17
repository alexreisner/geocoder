# encoding: utf-8
require 'test_helper'

class IpqualityscoreTest < GeocoderTestCase

  def setup
    super
    # configuring this IP lookup as the address lookup is weird, but necessary
    # in order to run tests with the 'quota exceeded' fixture
    Geocoder.configure(lookup: :ipqualityscore, ip_lookup: :ipqualityscore)
    set_api_key!(:ipqualityscore)
  end

  def test_result_attributes
    result = Geocoder.search('74.200.247.59').first

    # Request
    assert_equal('3YqddtowOADDvCm', result.request_id)
    assert_equal(true, result.success?)
    assert_equal('Success', result.message)

    # Geolocation
    assert_equal(40.73, result.latitude)
    assert_equal(-74.04, result.longitude)
    assert_equal 'Jersey City, New Jersey, US', result.address
    assert_equal('Jersey City', result.city)
    assert_equal('New Jersey', result.state)
    assert_equal('US', result.country_code)

    # Fallbacks for data API doesn't provide
    assert_equal('New Jersey', result.state_code)
    assert_equal('New Jersey', result.province_code)
    assert_equal('', result.postal_code)
    assert_equal('US', result.country)

    # Security
    assert_equal(false, result.mobile?)
    assert_equal(78, result.fraud_score)
    assert_equal('Rackspace Hosting', result.isp)
    assert_equal(19994, result.asn)
    assert_equal('Rackspace Hosting', result.organization)
    assert_equal(false, result.crawler?)
    assert_equal('74.200.247.59', result.host)
    assert_equal(true, result.proxy?)
    assert_equal(true, result.vpn?)
    assert_equal(false, result.tor?)
    assert_equal(false, result.active_vpn?)
    assert_equal(false, result.active_tor?)
    assert_equal(false, result.recent_abuse?)
    assert_equal(false, result.bot?)
    assert_equal('Corporate', result.connection_type)
    assert_equal('low', result.abuse_velocity)

    # Timezone
    assert_equal('America/New_York', result.timezone)
  end

  def test_raises_invalid_api_key_exception
    Geocoder.configure always_raise: :all
    assert_raises Geocoder::InvalidApiKey do
      Geocoder::Lookup::Ipqualityscore.new.send(:results, Geocoder::Query.new('invalid api key'))
    end
  end

  def test_raises_invalid_request_exception
    Geocoder.configure always_raise: :all
    assert_raises Geocoder::InvalidRequest do
      Geocoder::Lookup::Ipqualityscore.new.send(:results, Geocoder::Query.new('invalid request'))
    end
  end

  def test_raises_over_query_limit_exception_insufficient_credits
    Geocoder.configure always_raise: :all
    assert_raises Geocoder::OverQueryLimitError do
      Geocoder::Lookup::Ipqualityscore.new.send(:results, Geocoder::Query.new('insufficient credits'))
    end
  end

  def test_raises_over_query_limit_exception_quota_exceeded
    Geocoder.configure always_raise: :all
    assert_raises Geocoder::OverQueryLimitError do
      Geocoder::Lookup::Ipqualityscore.new.send(:results, Geocoder::Query.new('quota exceeded'))
    end
  end

  def test_unsuccessful_response_without_raising_does_not_hit_cache
    Geocoder.configure(cache: {}, always_raise: [])
    lookup = Geocoder::Lookup.get(:ipqualityscore)

    Geocoder.search('quota exceeded')
    assert_false lookup.instance_variable_get(:@cache_hit)

    Geocoder.search('quota exceeded')
    assert_false lookup.instance_variable_get(:@cache_hit)
  end

  def test_unsuccessful_response_with_raising_does_not_hit_cache
    Geocoder.configure(cache: {}, always_raise: [Geocoder::OverQueryLimitError])
    lookup = Geocoder::Lookup.get(:ipqualityscore)

    assert_raises Geocoder::OverQueryLimitError do
      Geocoder.search('quota exceeded')
    end
    assert_false lookup.instance_variable_get(:@cache_hit)

    assert_raises Geocoder::OverQueryLimitError do
      Geocoder.search('quota exceeded')
    end
    assert_false lookup.instance_variable_get(:@cache_hit)
  end

end
