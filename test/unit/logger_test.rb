# encoding: utf-8
require 'test_helper'
require 'logger'
require 'tempfile'

class LoggerTest < GeocoderTestCase

  def setup
    @tempfile = Tempfile.new("log")
    @logger = Logger.new(@tempfile.path)
    Geocoder.configure(logger: @logger)
  end

  def teardown
    @logger.close
    @tempfile.close
  end

  def test_set_logger_logs
    assert_equal nil, Geocoder.log(:warn, "should log")
    assert_match(/should log\n$/, @tempfile.read)
  end

  def test_logger_does_not_log_severity_too_low
    @logger.level = Logger::ERROR
    Geocoder.log(:info, "should not log")
    assert_equal "", @tempfile.read
  end

  def test_logger_logs_when_severity_high_enough
    @logger.level = Logger::DEBUG
    Geocoder.log(:warn, "important: should log!")
    assert_match(/important: should log/, @tempfile.read)
  end

  def test_kernel_logger_does_not_log_severity_too_low
    assert_nothing_raised do
      Geocoder.configure(logger: :kernel, kernel_logger_level: ::Logger::FATAL)
      Geocoder.log(:info, "should not log")
    end
  end

  def test_kernel_logger_logs_when_severity_high_enough
    assert_raises RuntimeError do
      Geocoder.configure(logger: :kernel, kernel_logger_level: ::Logger::DEBUG)
      Geocoder.log(:error, "important: should log!")
    end
  end

  def test_raise_configruation_error_for_invalid_logger
    Geocoder.configure(logger: {})
    assert_raises Geocoder::ConfigurationError do
      Geocoder.log(:info, "should raise error")
    end
  end

  def test_set_logger_always_returns_nil
    assert_equal nil, Geocoder.log(:info, "should log")
  end

  def test_kernel_logger_always_returns_nil
    Geocoder.configure(logger: :kernel)
    silence_warnings do
      assert_equal nil, Geocoder.log(:warn, "should log")
    end
  end
end
