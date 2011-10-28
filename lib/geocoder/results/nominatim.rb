require 'geocoder/results/base'

module Geocoder::Result
  class Nominatim < Base

    def house_number
      @data['address']['house_number']
    end

    def address
      @data['display_name']
    end

    def street
      @data['address']['road']
    end

    def city
      @data['address']['city']
    end

    def village
      @data['address']['villiage']
    end

    def town
      @data['address']['town']
    end

    def state
      @data['address']['state']
    end

    alias_method :state_code, :state

    def postal_code
      @data['address']['postcode']
    end

    def county
      @data['address']['county']
    end

    def country
      @data['address']['country']
    end

    def country_code
      @data['address']['country_code']
    end

    def coordinates
      [@data['lat'].to_f, @data['lon'].to_f]
    end

    def self.response_attributes
      %w[place_id, osm_type, osm_id, boundingbox, license,
         polygonpoints, display_name, class, type, stadium, suburb]
    end

    response_attributes.each do |a|
      define_method a do
        @data[a]
      end
    end
  end
end
