module Geocoder
  class IpAddress < String

    def loopback?
      valid? and (self == "0.0.0.0" or self.match(/\A127\./))
    end

    def valid?
      !!self.match(/\A(::ffff:)?(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\z/)
    end
  end
end
