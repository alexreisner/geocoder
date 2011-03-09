module Geocoder
  class Configuration
    def self.timeout; @@timeout; end
    def self.timeout=(obj); @@timeout = obj; end

    def self.lookup; @@lookup; end
    def self.lookup=(obj); @@lookup = obj; end
    
    def self.google_language; @@google_language; end
    def self.google_language=(obj); @@google_language = obj; end

    def self.yahoo_appid; @@yahoo_appid; end
    def self.yahoo_appid=(obj); @@yahoo_appid = obj; end
  end
end

Geocoder::Configuration.timeout         = 3
Geocoder::Configuration.lookup          = :google
Geocoder::Configuration.google_language = :en
Geocoder::Configuration.yahoo_appid     = ""
