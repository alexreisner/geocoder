# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..")
require 'test_helper'

class SimpleExecutionStrategyTest < GeocoderTestCase

  def test_strategy_calls_execute_on_lookup
    lookup = MiniTest::Mock.new
    lookup.expect(:search, [], ['search', {}])

    subject.execute(lookup, 'search', {})
    lookup.verify
  end

  def test_strategy_returns_lookup_results
    lookup = lookup_mock
    def lookup.search(text, opts)
      []
    end
    results = subject.execute(lookup, 'search', {})

    assert_equal [], results
  end

  private

  def lookup_mock
    MiniTest::Mock.new
  end

  def subject
    Geocoder::SimpleExecutionStrategy.new
  end
end
