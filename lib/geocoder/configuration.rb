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

        # URL of HTTP proxy
        [:http_proxy, nil],

        # URL of HTTPS proxy
        [:https_proxy, nil],

        # API key for geocoding service
        [:api_key, nil],

        # cache object (must respond to #[], #[]=, and #keys)
        [:cache, nil],

        # prefix (string) to use for all cache keys
        [:cache_prefix, "geocoder:"]
      ]
    end

    # define getters and setters for all configuration settings
    self.options_and_defaults.each do |o,d|
      eval("def self.#{o}; @@#{o}; end")
      eval("def self.#{o}=(obj); @@#{o} = obj; end")
    end

    # legacy support
    def self.yahoo_app_id=(value)
      warn "DEPRECATION WARNING: Geocoder's 'yahoo_app_id' setting has been replaced by 'api_key'. " +
        "This method will be removed in Geocoder v1.0."
      @@api_key = value
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
