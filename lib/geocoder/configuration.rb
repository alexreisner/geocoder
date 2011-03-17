module Geocoder
  class Configuration

    # geocoding service timeout (secs)
    def self.timeout; @@timeout; end
    def self.timeout=(obj); @@timeout = obj; end

    # name of geocoding service (symbol)
    def self.lookup; @@lookup; end
    def self.lookup=(obj); @@lookup = obj; end

    # ISO-639 language code
    def self.language; @@language; end
    def self.language=(obj); @@language = obj; end

    # app id (if using Yahoo geocoding service)
    def self.yahoo_appid; @@yahoo_appid; end
    def self.yahoo_appid=(obj); @@yahoo_appid = obj; end

    # API key (if using Google geocoding service)
    def self.google_api_key; @@google_api_key; end
    def self.google_api_key=(obj); @@google_api_key = obj; end

    # cache object (must respond to #[], #[]=, and #keys
    def self.cache; @@cache; end
    def self.cache=(obj); @@cache = obj; end

    # cache object (must respond to #[], #[]=, and #keys
    def self.cache_prefix; @@cache_prefix; end
    def self.cache_prefix=(obj); @@cache_prefix = obj; end

    # use HTTPS for lookup requests? (true or false)
    def self.use_https; @@use_https; end
    def self.use_https=(obj); @@use_https = obj; end
  end
end

Geocoder::Configuration.timeout        = 3
Geocoder::Configuration.lookup         = :google
Geocoder::Configuration.language       = :en
Geocoder::Configuration.yahoo_appid    = nil
Geocoder::Configuration.google_api_key = nil
Geocoder::Configuration.cache          = nil
Geocoder::Configuration.cache_prefix   = "geocoder:"
Geocoder::Configuration.use_https      = false
