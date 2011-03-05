require 'geocoder'
require 'geocoder/results/freegeoip'

module Geocoder
  module Request

    def location
      if ip.nil? or ip == "0.0.0.0" or ip.match /^127/ # don't look up loopback
        # but return a Geocoder::Result for consistency
        Geocoder::Result::Freegeoip.new("ip" => ip)
      else
        Geocoder.search(ip).first
      end
    end
  end
end

if defined?(Rack) and defined?(Rack::Request)
  Rack::Request.send :include, Geocoder::Request
end
