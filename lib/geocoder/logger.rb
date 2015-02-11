require 'logger'

module Geocoder

  def self.log(level, message)
    Logger.instance.log(level, message)
  end

  class Logger
    include Singleton

    SEVERITY = {
      debug: Logger::Severity::DEBUG,
      info: Logger::Severity::INFO,
      warn: Logger::Severity::WARN,
      error: Logger::Severity::ERROR,
      fatal: Logger::Severity::FATAL
    }

    def log(level, message)
      logger = config[:logger]
      return true unless logger && valid_level?(level)

      if logger == :default
        kernel_log(level, message)
      else
        logger.log(SEVERITY[level], message)
      end
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
      [:debug, :info, :warn, :error, :fatal].includes? level
    end
  end
end
