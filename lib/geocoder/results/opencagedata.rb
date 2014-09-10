require 'geocoder/results/base'

module Geocoder::Result
  class Opencagedata < Base

    def poi
      %w[stadium bus_stop tram_stop].each do |key|
        return @data['components'][key] if @data['components'].key?(key)
      end
      return nil
    end

    def house_number
      @data['components']['house_number']
    end

    def address
      @data['formatted']
    end

    def street
      %w[road pedestrian highway].each do |key|
        return @data['components'][key] if @data['components'].key?(key)
      end
      return nil
    end

    def city
      %w[city town village hamlet].each do |key|
        return @data['components'][key] if @data['components'].key?(key)
      end
      return nil
    end

    def village
      @data['components']['village']
    end


    def state
      @data['components']['state']
    end

    alias_method :state_code, :state

    def postal_code
      @data['components']['postcode'].to_s
    end

    def county
      @data['components']['county']
    end

    def country
      @data['components']['country']
    end

    def country_code
      @data['components']['country_code']
    end

    def suburb
      @data['components']['suburb']
    end

    def coordinates
      [@data['geometry']['lat'].to_f, @data['geometry']['lng'].to_f]
    end
    def self.response_attributes
      %w[boundingbox license 
        formatted stadium]
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
