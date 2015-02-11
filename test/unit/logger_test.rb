# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..")
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

  def test_nil_logger_does_not_log
    Geocoder.configure(logger: nil)
    assert_equal true, Geocoder.log(:warn, "should not log")
  end

  def test_set_logger_logs
    Geocoder.log(:warn, "should log")
    assert_equal "should log\n", @tempfile.read
  end

  def test_set_logger_does_not_log_severity_too_low
    @logger.level = Logger::ERROR
    assert_equal true, Geocoder.log(:info, "should not log")
    assert_equal "", @tempfile.read
  end
end
