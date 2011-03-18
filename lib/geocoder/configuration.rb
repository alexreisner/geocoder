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

        # app id (if using Yahoo geocoding service)
        [:yahoo_appid, nil],

        # API key (if using Google geocoding service)
        [:google_api_key, nil],

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
