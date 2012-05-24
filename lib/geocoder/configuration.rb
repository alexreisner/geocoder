require 'singleton'

module Geocoder

  ##
  # Provides convenient access to the Configuration singleton.
  #
  def self.configure(&block)
    if block_given?
      block.call(Configuration.instance)
    else
      Configuration.instance
    end
  end

  ##
  # This class handles geocoder Geocoder configuration
  # (geocoding service provider, caching, units of measurement, etc).
  # Configuration can be done in two ways:
  #
  # 1) Using Geocoder.configure and passing a block
  #    (useful for configuring multiple things at once):
  #
  #   Geocoder.configure do |config|
  #     config.timeout      = 5
  #     config.lookup       = :yahoo
  #     config.api_key      = "2a9fsa983jaslfj982fjasd"
  #     config.units        = :km
  #   end
  #
  # 2) Using the Geocoder::Configuration singleton directly:
  #
  #   Geocoder::Configuration.language = 'pt-BR'
  #
  # Default values are defined in Configuration#set_defaults.
  #
  class Configuration
    include Singleton

    OPTIONS = [
      :timeout,
      :lookup,
      :language,
      :http_headers,
      :use_https,
      :http_proxy,
      :https_proxy,
      :api_key,
      :cache,
      :cache_prefix,
      :always_raise,
      :units,
      :distances
    ]

    attr_accessor *OPTIONS

    def initialize # :nodoc
      set_defaults
    end

    def set_defaults
      @timeout      = 3           # geocoding service timeout (secs)
      @lookup       = :google     # name of geocoding service (symbol)
      @language     = :en         # ISO-639 language code
      @http_headers = {}          # HTTP headers for lookup
      @use_https    = false       # use HTTPS for lookup requests? (if supported)
      @http_proxy   = nil         # HTTP proxy server (user:pass@host:port)
      @https_proxy  = nil         # HTTPS proxy server (user:pass@host:port)
      @api_key      = nil         # API key for geocoding service
      @cache        = nil         # cache object (must respond to #[], #[]=, and #keys)
      @cache_prefix = "geocoder:" # prefix (string) to use for all cache keys

      # exceptions that should not be rescued by default
      # (if you want to implement custom error handling);
      # supports SocketError and TimeoutError
      @always_raise = []

      # calculation options
      @units     = :mi     # :mi or :km
      @distances = :linear # :linear or :spherical
    end

    instance_eval(OPTIONS.map do |option|
      o = option.to_s
      <<-EOS
      def #{o}
        instance.#{o}
      end

      def #{o}=(value)
        instance.#{o} = value
      end
      EOS
    end.join("\n\n"))

    class << self
      def set_defaults
        instance.set_defaults
      end
    end
  end
end
