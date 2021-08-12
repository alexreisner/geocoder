require 'geocoder/results/base'

module Geocoder::Result
  class NetToolKit < Base

    def address
      @data['address']
    end
    
    def coordinates
      %w[latitude longitude].map{ |l| @data[l] }
    end

    def house_number
      @data['house_number']
    end

    def street
       @data['street']
    end

    def street_name
       @data['street_name']
    end

    def street_type
       @data['street_type']
    end

    def city
      @data['city']
    end

    def county
      @data['county']
    end

    def state
      @data['state']
    end

    def state_code
      @data['state_code']
    end

    def postal_code
      @data['postcode']
    end

    def precision
      @data['precision']
    end

    def provider
      @data['provider']
    end

    def ntk_geocode_time
      @data['ntk_geocode_time']
    end
  end
end
