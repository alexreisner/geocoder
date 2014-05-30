# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..")
require 'test_helper'

class ExecutionStrategyFactoryTest < GeocoderTestCase

  def test_with_no_configuration
    assert subject.strategy.is_a?(Geocoder::SimpleExecutionStrategy)
  end

  def test_with_valid_fallback_configuration_setting
    Geocoder.configure(:lookup_fallback => {
        :to => :google,
        :on => Geocoder::OverQueryLimitError
    })

    assert subject.strategy.is_a?(Geocoder::FallbackExecutionStrategy)
  end

  def test_with_fallback_configuration_missing_to
    Geocoder.configure(:lookup_fallback => {
        :on => Geocoder::OverQueryLimitError
    })

    assert subject.strategy.is_a?(Geocoder::SimpleExecutionStrategy)
  end

  def test_with_fallback_configuration_missing_on
    Geocoder.configure(:lookup_fallback => {
        :to => :google,
    })

    assert subject.strategy.is_a?(Geocoder::SimpleExecutionStrategy)
  end

  private

  def subject
    Geocoder::ExecutionStrategyFactory.new
  end
end
