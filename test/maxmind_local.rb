# encoding: utf-8
require 'test_helper'

class MaxmindLocalTest < Test::Unit::TestCase
  def test_it_requires_database_path
    g = Geocoder::Lookup::MaxmindLocal.new

    assert_raise Geocoder::ConfigurationError do
      g.search(Geocoder::Query.new('8.8.8.8')).first
    end
  end
end