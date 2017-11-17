require 'test_helper'

class DbIpComTest < GeocoderTestCase
  def configure_for_free_api_access
    Geocoder.configure(ip_lookup: :db_ip_com, db_ip_com: { api_key: 'MY_API_KEY' })
    set_api_key!(:db_ip_com)
  end

  def configure_for_paid_api_access
    Geocoder.configure(ip_lookup: :db_ip_com, db_ip_com: { api_key: 'MY_API_KEY', use_https: true })
    set_api_key!(:db_ip_com)
  end

  def teardown
    Geocoder::Configuration.instance.set_defaults
  end

  def test_no_results
    configure_for_free_api_access
    results = Geocoder.search('no results')
    assert_equal 0, results.length
  end

  def test_result_on_ip_address_search
    configure_for_free_api_access
    result = Geocoder.search('23.255.240.0').first
    assert result.is_a?(Geocoder::Result::DbIpCom)
  end

  def test_result_components
    configure_for_free_api_access
    result = Geocoder.search('23.255.240.0').first

    assert_equal [37.3861, -122.084], result.coordinates
    assert_equal 'Mountain View, California 94043, United States', result.address
    assert_equal 'Mountain View', result.city
    assert_equal 'Santa Clara County', result.district
    assert_equal 'California', result.state_code
    assert_equal '94043', result.zip_code
    assert_equal 'United States', result.country_name
    assert_equal 'US', result.country_code
    assert_equal 'North America', result.continent_name
    assert_equal 'NA', result.continent_code
    assert_equal 'America/Los_Angeles', result.time_zone
    assert_equal(-7, result.gmt_offset)
    assert_equal 'USD', result.currency_code
  end

  def test_free_host_config
    configure_for_free_api_access
    lookup = Geocoder::Lookup::DbIpCom.new
    query = Geocoder::Query.new('23.255.240.0')
    assert_match 'http://api.db-ip.com/v2/MY_API_KEY/23.255.240.0', lookup.query_url(query)
  end

  def test_paid_host_config
    configure_for_paid_api_access
    lookup = Geocoder::Lookup::DbIpCom.new
    query = Geocoder::Query.new('23.255.240.0')
    assert_match 'https://api.db-ip.com/v2/MY_API_KEY/23.255.240.0', lookup.query_url(query)
  end

  def test_raises_over_limit_exception
    Geocoder.configure always_raise: :all
    assert_raises Geocoder::OverQueryLimitError do
      Geocoder::Lookup::DbIpCom.new.send(:results, Geocoder::Query.new('quota exceeded'))
    end
  end

  def test_raises_unknown_error
    Geocoder.configure always_raise: :all
    assert_raises Geocoder::Error do
      Geocoder::Lookup::DbIpCom.new.send(:results, Geocoder::Query.new('unknown error'))
    end
  end
end
