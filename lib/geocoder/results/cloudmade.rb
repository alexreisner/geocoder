require 'geocoder/results/base'

module Geocoder::Result
  class Cloudmade < Base

    def coordinates
      @data["centroid"]["coordinates"]
    end

    def street
      @data["location"]["road"]
    end

    def city
      @data["location"]["city"]
    end
    
    def state
      @data["location"]["county"]
    end
    alias_method :state_code, :state

    def country
      @data["location"]["country"]
    end
    alias_method :country_code, :country

    def postal_code
      @data["location"]["postcode"]
    end

    def address
      [street, city, state, postal_code, country].compact.reject{|s| s.length == 0 }.join(", ")
    end

  end
end


