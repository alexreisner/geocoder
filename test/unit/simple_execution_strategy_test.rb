# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..")
require 'test_helper'

class SimpleExecutionStrategyTest < GeocoderTestCase

  def setup
    query = Geocoder::Query.new("test")
    @subject = Geocoder::SimpleExecutionStrategy.new(query, lookup: :google)
  end

  def test_strategy_returns_lookup_results
    results = @subject.search
    assert_equal 1, results.size
  end

  def test_strategy_used_correct_lookup
    results = @subject.search
    assert_instance_of Geocoder::Result::Google, results.first
  end
end
