module Geocoder
  class IpAddress < String

    def loopback?
      valid? and (self == "0.0.0.0" or self.match(/\A127\./))
    end

    def valid?
      ipregex = %r{
        \A(                                     # String Starts
        ((::ffff:)?((\d{1,3})\.){3}\d{1,3})     # Check for IPv4
        |                                       # .... Or
        (\S+?(:\S+?){6}\S+)                     # Check for IPv6
        )\z                                     
      }x
      !!self.match(ipregex)
    end
  end
end
