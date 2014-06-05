# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..")
require 'test_helper'

class FallbackExecutionStrategyTest < GeocoderTestCase

  def teardown
    Geocoder.configure(:always_raise => [], :lookup_fallback => {})
  end

  def test_strategy_returns_lookup_results
    lookup = Geocoder::Lookup.get(:google)
    results = subject.execute(lookup, 'search', {})

    assert_equal 1, results.size
  end

  def test_strategy_does_fallback_when_exception_occurs
    Geocoder.configure(:lookup => :yandex,
        :lookup_fallback => {
        :to => :google,
        :on => Geocoder::OverQueryLimitError
    })
    lookup = lookup_mock
    def lookup.search(text, opts)
      raise Geocoder::OverQueryLimitError
    end

    assert_nothing_raised do
      results = subject.execute(lookup, 'search', {})
      assert results.first.is_a?(Geocoder::Result::Google)
    end
  end

  def test_strategy_raises_error_when_other_exception_occurs
    Geocoder.configure(:lookup => :yandex,
        :always_raise => [TimeoutError],
        :lookup_fallback => {
        :to => :google,
        :on => Geocoder::OverQueryLimitError
    })
    lookup = lookup_mock
    def lookup.search(text, opts)
      raise Geocoder::OverQueryLimitError
    end

    assert_raises TimeoutError do
      results = subject.execute(lookup, 'timeout', {})
    end
  end

  def test_strategy_does_not_raise_error_when_not_set
    Geocoder.configure(:lookup => :yandex,
        :always_raise => [],
        :lookup_fallback => {
        :to => :google,
        :on => TimeoutError
    })
    lookup = lookup_mock
    def lookup.search(text, opts)
      raise TimeoutError
    end

    assert_nothing_raised do
      results = subject.execute(lookup, 'timeout', {})
    end
  end

  def test_strategy_raises_error_from_fallback_if_retry_limit_breached
    Geocoder.configure(:lookup => :yandex,
        :always_raise => [TimeoutError],
        :lookup_fallback => {
        :to => :google,
        :on => TimeoutError
    })
    lookup = lookup_mock
    def lookup.search(text, opts)
      raise TimeoutError
    end

    assert_raises TimeoutError do
      results = subject.execute(lookup, 'timeout', {})
    end
  end

def test_strategy_does_not_raise_error_from_fallback_if_retry_limit_breached
    Geocoder.configure(:lookup => :yandex,
        :always_raise => [],
        :lookup_fallback => {
        :to => :google,
        :on => TimeoutError
    })
    lookup = lookup_mock
    def lookup.search(text, opts)
      raise TimeoutError
    end

    assert_nothing_raised do
      results = subject.execute(lookup, 'timeout', {})
    end
  end

  def test_strategy_ignores_invalid_error
    Geocoder.configure(:lookup => :yandex,
        :lookup_fallback => {
        :to => :google,
        :on => 'foo'
    })
    lookup = lookup_mock
    def lookup.search(text, opts)
      []
    end

    assert_nothing_raised do
      results = subject.execute(lookup, 'search', {})
    end
  end

  def test_strategy_ignores_invalid_fallback_config
    Geocoder.configure(:lookup => :yandex,
        :lookup_fallback => {
        :to => :google
    })
    lookup = lookup_mock
    def lookup.search(text, opts)
      []
    end

    assert_nothing_raised do
      results = subject.execute(lookup, 'search', {})
    end
  end

  private

  def lookup_mock
    MiniTest::Mock.new
  end

  def subject
    Geocoder::FallbackExecutionStrategy.new
  end
end
