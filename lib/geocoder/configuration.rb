require 'singleton'

module Geocoder
  class Configuration
    include Singleton

    CONFIGURABLE = [:timeout     , :lookup    , :language    ,
                    :use_https   , :http_proxy, :https_proxy ,
                    :api_key     , :cache     , :cache_prefix,
                    :always_raise, :units     , :method      ]

    attr_accessor *CONFIGURABLE

    def initialize
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

      # Calculation options
      @units  = :km        # Internationl System standard unit for distance
      @method = :spherical # More precise
    end

    # delegates getters and setters for all configuration settings to the instance
    instance_eval(CONFIGURABLE.map do |method|
      meth = method.to_s
      <<-EOS
      def #{meth}
        instance.#{meth}
      end

      def #{meth}=(value)
        instance.#{meth} = value
      end
      EOS
    end.join("\n\n"))
  end
end

