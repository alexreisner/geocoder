require 'singleton'

module Geocoder

  # This class handle the configuration process of Geocoder gem, and can be used
  # to change some functional aspects, like, the geocoding service provider, or
  # the units of calculations.
  #
  # == Geocoder Configuration
  #
  # The configuration of Geocoder can be done in to ways:
  # @example Using +Geocoder#configure+ method:
  #
  #   Geocoder.configure do
  #     config.timeout      = 3           # geocoding service timeout (secs)
  #     config.lookup       = :google     # name of geocoding service (symbol)
  #     config.language     = :en         # ISO-639 language code
  #     config.use_https    = false       # use HTTPS for lookup requests? (if supported)
  #     config.http_proxy   = nil         # HTTP proxy server (user:pass@host:port)
  #     config.https_proxy  = nil         # HTTPS proxy server (user:pass@host:port)
  #     config.api_key      = nil         # API key for geocoding service
  #     config.cache        = nil         # cache object (must respond to #[], #[]=, and #keys)
  #     config.cache_prefix = "geocoder:" # prefix (string) to use for all cache keys
  #
  #     # exceptions that should not be rescued by default
  #     # (if you want to implement custom error handling);
  #     # supports SocketError and TimeoutError
  #     config.always_raise = []
  #
  #     # Calculation options
  #     config.units  = :mi        # :km for kilometers or :mi for miles
  #     config.method = :linear    # :spherical or :linear
  #   end
  #
  # @example Using +Geocoder::Configuration+ class directly, like in:
  #
  #   Geocoder::Configuration.language = 'pt-BR'
  #
  # == Notes
  #
  # All configurations are optional, the default values were shown in the first
  # example (with +Geocoder#configure+).

  class Configuration
    include Singleton

    OPTIONS = [
      :timeout,
      :lookup,
      :language,
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

    def initialize  # :nodoc
      set_defaults
    end

    # This method will set the configuration options to the default values
    def set_defaults
      @timeout      = 3           # geocoding service timeout (secs)
      @lookup       = :google     # name of geocoding service (symbol)
      @language     = :en         # ISO-639 language code
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

    # Delegates getters and setters for all configuration settings,
    # and +set_defaults+ to the singleton instance.
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
      # This method will set the configuration options to the default values
      def set_defaults
        instance.set_defaults
      end
    end
  end
end
