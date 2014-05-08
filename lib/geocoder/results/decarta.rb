require 'geocoder/results/base'

module Geocoder::Result
  class Decarta < Base

    def address
      @data['address']
    end

    def street
      @data['address']['streetName']
    end

    def city
      @data['address']['municipality']
    end

    def state
      @data['address']['countrySubdivision']
    end

    def postal_code
      @data['address']['postalCode']
    end

    def country_code
      @data['address']['countryCode']
    end

    def coordinates
      [@data['position']['lat'].to_f, @data['position']['lon'].to_f]
    end

    def place_type
      @data['type']
    end

  end
end
