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

  def test_strategy_uses_correct_lookup
    results = @subject.search
    assert_instance_of Geocoder::Result::Google, results.first
  end

  def test_strategy_uses_correct_lookup_with_fallback_on_skip
    query = Geocoder::Query.new("foobar")
    subject = Geocoder::FallbackExecutionStrategy.new(query, lookup: [fallback_option_yandex, fallback_option_google])

    results = subject.search
    assert_instance_of Geocoder::Result::Google, results.first
  end

  def test_strategy_calls_predicates_for_each_lookup
    skip_count = 0
    fail_count = 0
    fallback_option_yandex = {
      :name => :yandex,
      :skip => ->(query) { skip_count += 1; false },
      :failure => ->(results, exception) { fail_count += 1; false }
    }
    fallback_option_google = {
      :name => :google,
      :skip => nil,
      :failure => nil
    }

    query = Geocoder::Query.new("test")
    subject = Geocoder::FallbackExecutionStrategy.new(query, lookup: [fallback_option_yandex, fallback_option_google])
    subject.search

    assert_equal 1, skip_count
    assert_equal 1, fail_count
  end

  def test_strategy_calls_predicates_for_each_lookup_if_specified
    skip_count = 0
    fail_count = 0
    fallback_option_yandex = {
      :name => :yandex,
      :skip => ->(query) { skip_count += 1; false },
      :failure => ->(results, exception) { fail_count += 1; true }
    }
    fallback_option_google = {
      :name => :google,
      :skip => ->(query) { skip_count += 1; false },
      :failure => ->(results, exception) { fail_count += 1; false }
    }

    query = Geocoder::Query.new("test")
    subject = Geocoder::FallbackExecutionStrategy.new(query, lookup: [fallback_option_yandex, fallback_option_google])
    subject.search

    assert_equal 2, skip_count
    assert_equal 2, fail_count
  end

  def test_strategy_ignores_predicates_if_nil
    skip_count = 0
    fail_count = 0
    fallback_option_yandex = {
      :name => :yandex,
      :skip => nil,
      :failure => nil
    }
    fallback_option_google = {
      :name => :google,
      :skip => ->(query) { skip_count += 1; false },
      :failure => ->(results, exception) { fail_count += 1; false }
    }

    query = Geocoder::Query.new("test")
    subject = Geocoder::FallbackExecutionStrategy.new(query, lookup: [fallback_option_yandex, fallback_option_google])
    subject.search

    assert_equal 0, skip_count
    assert_equal 0, fail_count
  end

  def test_strategy_uses_correct_lookup_with_fallback_on_failure
    fallback_option_yandex = {
      :name => :yandex,
      :skip => ->(query) { query.text.match(/foobar/i) },
      :failure => ->(results, exception) { true }
    }
    query = Geocoder::Query.new("test")
    subject = Geocoder::FallbackExecutionStrategy.new(query, lookup: [fallback_option_yandex, fallback_option_google])

    results = subject.search
    assert_instance_of Geocoder::Result::Google, results.first
  end

  def test_strategy_raises_exception_on_correct_lookup
    skip_count = 0
    fallback_option_yandex = {
      :name => :yandex,
      :skip => ->(query) { skip_count += 1; false },
      :failure => ->(results, exception) { exception.class == SocketError }
    }
    fallback_option_google = {
      :name => :google,
      :skip => ->(query) { skip_count += 1; false },
      :failure => nil
    }

    Geocoder.configure(:always_raise => [SocketError])
    query = Geocoder::Query.new("socket_error")
    subject = Geocoder::FallbackExecutionStrategy.new(query, lookup: [fallback_option_yandex, fallback_option_google])

    assert_raises SocketError do
      subject.search
    end
    assert_equal 2, skip_count
  end

  private

  def fallback_option_yandex
    {
      :name => :yandex,
      :skip => ->(query) { query.text.match(/foobar/i) },
      :failure => ->(results, exception) { exception.class == SocketError }
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
