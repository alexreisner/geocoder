module Geocoder
  class Configuration

    def self.options_and_defaults
      [
        # geocoding service timeout (secs)
        [:timeout, 3],

        # name of geocoding service (symbol)
        [:lookup, :google],

        # ISO-639 language code
        [:language, :en],

        # use HTTPS for lookup requests? (if supported)
        [:use_https, false],

        # HTTP proxy server (user:pass@host:port)
        [:http_proxy, nil],

        # HTTPS proxy server (user:pass@host:port)
        [:https_proxy, nil],

        # API key for geocoding service
        [:api_key, nil],

        # cache object (must respond to #[], #[]=, and #keys)
        [:cache, nil],

        # prefix (string) to use for all cache keys
        [:cache_prefix, "geocoder:"],

        # exceptions that should not be rescued by default
        # (if you want to implement custom error handling);
        # supports SocketError and TimeoutError
        [:always_raise, []]
      ]
    end

    # define getters and setters for all configuration settings
    self.options_and_defaults.each do |o,d|
      eval("def self.#{o}; @@#{o}; end")
      eval("def self.#{o}=(obj); @@#{o} = obj; end")
    end

    ##
    # Set all values to default.
    #
    def self.set_defaults
      self.options_and_defaults.each do |o,d|
        self.send("#{o}=", d)
      end
    end
  end
end

Geocoder::Configuration.set_defaults
