require 'resolv'
module Geocoder
  class IpAddress < String

    def loopback?
      valid? and (self == "0.0.0.0" or self.match(/\A127\./) or self == "::1")
    end

    def valid?
      !!((self =~ Resolv::IPv4::Regex) || (self =~ Resolv::IPv6::Regex))
    end
  end
end
