# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..")
require 'test_helper'

class FallbackExecutionStrategyTest < GeocoderTestCase

  def setup
    query = Geocoder::Query.new("test")
    @subject = Geocoder::FallbackExecutionStrategy.new(query, lookup: [fallback_option_google, fallback_option_yandex])
  end

  def test_strategy_returns_lookup_results
    results = @subject.search
    assert_equal 1, results.size
  end

  def test_strategy_used_correct_lookup
    results = @subject.search
    assert_instance_of Geocoder::Result::Google, results.first
  end

  def test_strategy_used_correct_lookup_with_fallback
    query = Geocoder::Query.new("foobar")
    subject = Geocoder::FallbackExecutionStrategy.new(query, lookup: [fallback_option_yandex, fallback_option_google])

    results = subject.search
    assert_instance_of Geocoder::Result::Google, results.first
  end

  private

  def fallback_option_yandex
    {
      :name => :yandex,
      :skip => ->(query) { query.text.match(/foobar/i) },
      :failure => ->(results, exception) { exception.class == Geocoder::OverQueryLimitError }
    }
  end

  def fallback_option_google
    {
      :name => :google,
      :skip => nil,
      :failure => nil
    }
  end
end
