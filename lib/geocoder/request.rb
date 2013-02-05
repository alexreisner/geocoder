require 'geocoder'

module Geocoder
  module Request

    def location
      unless defined?(@location)
        if env.has_key?('HTTP_X_REAL_IP')
          @location = Geocoder.search(env['HTTP_X_REAL_IP']).first
        elsif env.has_key?('HTTP_X_FORWARDED_FOR')
          @location = Geocoder.search(env['HTTP_X_FORWARDED_FOR'].split(/\s*,\s*/)[0]).first
        else
          @location = Geocoder.search(ip).first
        end
      end
      @location
    end
  end
end

if defined?(Rack) and defined?(Rack::Request)
  Rack::Request.send :include, Geocoder::Request
end
