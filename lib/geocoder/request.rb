require 'geocoder'

module Geocoder
  module Request

    def location
      @location ||= begin
        detected_ip = env['HTTP_X_REAL_IP'] ||
          env['HTTP_X_FORWARDED_FOR'] && env['HTTP_X_FORWARDED_FOR'].split(",").first.strip

        real_ip = detected_ip && (detected_ip = IpAddress.new(detected_ip)) && detected_ip.valid? && !detected_ip.loopback? && detected_ip.to_s || self.ip
        Geocoder.search(real_ip).first
      end
    end
  end
end

if defined?(Rack) and defined?(Rack::Request)
  Rack::Request.send :include, Geocoder::Request
end
