module Geocoder
  class Configuration
    cattr_accessor :timeout, :lookup, :yahoo_appid
  end
end

Geocoder::Configuration.timeout     = 3
Geocoder::Configuration.lookup      = :google
Geocoder::Configuration.yahoo_appid = ""
