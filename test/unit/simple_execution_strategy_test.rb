# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..")
require 'test_helper'

class SimpleExecutionStrategyTest < GeocoderTestCase

  def test_strategy_returns_lookup_results
    results = subject.execute(lookup, 'search', {})

    assert_equal 1, results.size
  end

  private

  def lookup
    Geocoder::Lookup.get(:google)
  end

  def subject
    Geocoder::SimpleExecutionStrategy.new
  end
end
