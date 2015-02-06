module Geocoder
  module Request

    # This method is vulnerable to trivial IP spoofing.
    #   Don't use it in authorization/authentication code,
    #   or any other security-sensitive application.
    #   Use paranoid_location instead.
    def location
      @location ||= Geocoder.search(geocoder_spoofable_ip).first
    end

    # This method protects you from trivial IP spoofing.  For requests that go through a
    #   proxy that you haven't whitelisted as trusted in your Rack config, you will get
    #   the location for the IP of the last untrusted proxy in the chain, not the original
    #   client IP.  You WILL NOT get the location corresponding to the original client IP
    #   for any request sent through a non-whitelisted proxy.
    def paranoid_location
      @location ||= Geocoder.search(ip).first
    end

    # There's a whole zoo of nonstandard headers added by various
    #   proxy softwares to indicate original client IP.
    # ANY of these can be trivially spoofed!
    #   (except REMOTE_ADDR, which should by set by your server,
    #    and is included at the end as a fallback.
    GEOCODER_CANDIDATE_HEADERS = ['HTTP_X_REAL_IP',
                                  'HTTP_X_CLIENT_IP',
                                  'HTTP_CLIENT_IP',
                                  'HTTP_X_FORWARDED_FOR',
                                  'HTTP_X_FORWARDED',
                                  'HTTP_X_CLUSTER_CLIENT_IP',
                                  'HTTP_FORWARDED_FOR',
                                  'HTTP_FORWARDED',
                                  'REMOTE_ADDR']

    def geocoder_spoofable_ip
      GEOCODER_CANDIDATE_HEADERS.each do |header|
        if @env.has_key? header
          addrs = geocoder_split_ip_addresses(@env[header])
          addrs = geocoder_reject_trusted_ip_addresses(addrs)
          return addrs.first if addrs.any?
        end
      end

      @env['REMOTE_ADDR']
    end

    private

    def geocoder_split_ip_addresses(ip_addresses)
      ip_addresses ? ip_addresses.strip.split(/[,\s]+/) : []
    end

    # use Rack's trusted_proxy?() method to filter out IPs
    #   that have been configured as trusted; includes private ranges by default.
    def geocoder_reject_trusted_ip_addresses(ip_addresses)
      ip_addresses.reject { |ip| trusted_proxy?(ip) }
    end
  end
end

if defined?(Rack) and defined?(Rack::Request)
  Rack::Request.send :include, Geocoder::Request
end
