require 'geocoder/results/base'

module Geocoder::Result
  class Nominatim < Base

    def poi
      %w[stadium bus_stop tram_stop].each do |key|
        return @data['address'][key] if @data['address'].key?(key)
      end
      return nil
    end

    def house_number
      @data['address']['house_number']
    end

    def address
      @data['display_name']
    end

    def street
      %w[road pedestrian highway].each do |key|
        return @data['address'][key] if @data['address'].key?(key)
      end
      return nil
    end

    def city
      %w[city town village hamlet].each do |key|
        return @data['address'][key] if @data['address'].key?(key)
      end
      return nil
    end

    def village
      @data['address']['village']
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

    def suburb
      @data['address']['suburb']
    end

    def coordinates
      [@data['lat'].to_f, @data['lon'].to_f]
    end

    def place_class
      @data['class']
    end

    def place_type
      @data['type']
    end

    def self.response_attributes
      %w[place_id osm_type osm_id boundingbox license
         polygonpoints display_name class type stadium]
    end

    response_attributes.each do |a|
      unless method_defined?(a)
        define_method a do
          @data[a]
        end
      end
    end
  end
end
