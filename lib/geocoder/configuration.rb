module Geocoder
  class Configuration
    def self.timeout; @@timeout; end
    def self.timeout=(obj); @@timeout = obj; end

    def self.safe_mode; @@safe_mode; end
    def self.safe_mode=(obj); @@safe_mode = obj; end

    def self.lookup; @@lookup; end
    def self.lookup=(obj); @@lookup = obj; end

    def self.yahoo_appid; @@yahoo_appid; end
    def self.yahoo_appid=(obj); @@yahoo_appid = obj; end
  end
end

Geocoder::Configuration.timeout     = 3
Geocoder::Configuration.lookup      = :google
Geocoder::Configuration.yahoo_appid = ""
Geocoder::Configuration.safe_mode   = false
