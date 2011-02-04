module Geocoder
  class Configuration
    cattr_accessor :timeout
  end
end

Geocoder::Configuration.timeout = 3

