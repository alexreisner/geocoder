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
  end
end

Geocoder::Configuration.timeout     = 3
Geocoder::Configuration.lookup      = :google
Geocoder::Configuration.language    = :en
Geocoder::Configuration.yahoo_appid = ""
