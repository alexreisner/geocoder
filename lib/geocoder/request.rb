require 'geocoder'

module Geocoder
  module Request

    def location
      unless defined?(@location)
        @location = Geocoder.search(ip).first
      end
      @location
    end
  end
end

if defined?(Rack) and defined?(Rack::Request)
  Rack::Request.send :include, Geocoder::Request
end
