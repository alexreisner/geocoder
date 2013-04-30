# encoding: utf-8
require 'test_helper'

class MaxmindDatabaseTest < Test::Unit::TestCase
  def test_it_works
    Geocoder.configure(:path => File.join('test', 'fixtures', 'GeoLiteCity.dat'))

    g = Geocoder::Lookup::MaxmindDatabase.new
    result = g.search(Geocoder::Query.new('8.8.8.8')).first


    assert result.city, 'Mountain View'
    assert result.country_code, 'USA'
    assert result.latitude, '37.41919999999999'
    assert result.longitude, '-122.0574'
    assert result.state, 'CA'
    assert result.postal_code, '94043'
  end

  def test_it_requires_database_path
    g = Geocoder::Lookup::MaxmindDatabase.new

    assert_raise Geocoder::ConfigurationError do
      g.search(Geocoder::Query.new('8.8.8.8')).first
    end
  end
end