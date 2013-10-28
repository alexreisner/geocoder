require 'geocoder/results/base'

module Geocoder::Result
  class GeocoderUs < Base
    def coordinates
      [@data[0].to_f, @data[1].to_f]
    end

    def address(format = :full)
      "#{street_address}, #{city}, #{state} #{postal_code}, #{country}".sub(/^[ ,]*/, "")
    end

    def street_address
      @data[2]
    end

    def city
      @data[3]
    end

    def state
      @data[4]
    end

    alias_method :state_code, :state

    def postal_code
      @data[5]
    end

    def country
      'United States'
    end

    def country_code
      'US'
    end
  end
end
