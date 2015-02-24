require 'logger'

module Geocoder

  def self.log(level, message)
    Logger.instance.log(level, message)
  end

  class Logger
    include Singleton

    SEVERITY = {
      debug: ::Logger::DEBUG,
      info: ::Logger::INFO,
      warn: ::Logger::WARN,
      error: ::Logger::ERROR,
      fatal: ::Logger::FATAL
    }

    def log(level, message)
      return nil unless valid_level?(level)

      logger = Geocoder.config[:logger]

      if logger == :kernel
        kernel_log(level, message)
      elsif logger.kind_of? ::Logger
        logger.add(SEVERITY[level], message)
      else
        raise Geocoder::ConfigurationError, "Please specify valid logger for Geocoder. " +
        "Logger specified must be :kernel or must respond to `add(level, message)`."
      end
      nil
    end

    private

    def kernel_log(level, message)
      case level
      when :debug, :info
        puts message
      when :warn
        warn message
      when :error
        raise message
      when :fatal
        fail message
      end
    end

    def valid_level?(level)
      [:debug, :info, :warn, :error, :fatal].include? level
    end
  end
end
