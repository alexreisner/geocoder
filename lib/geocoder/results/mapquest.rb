require 'geocoder/results/base'

module Geocoder::Result
  class Mapquest < Base
    def latitude
      @data["latLng"]["lat"]
    end

    def longitude
      @data["latLng"]["lng"]
    end

    def coordinates
      [latitude, longitude]
    end

    def city
      @data['adminArea5']
    end

    def street
      @data['street']
    end

    def state
      @data['adminArea3']
    end

    alias_method :state_code, :state

    #FIXME: these might not be right, unclear with MQ documentation
    alias_method :province, :state
    alias_method :province_code, :state

    def postal_code
      @data['postalCode'].to_s
    end

    def country
      @data['adminArea1']
    end

    def country_code
      country
    end

    def address
      [street, city, state, postal_code, country].reject{|s| s.length == 0 }.join(", ")
    end
  end
end
