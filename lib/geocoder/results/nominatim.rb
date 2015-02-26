require 'geocoder/results/base'

module Geocoder::Result
  class Nominatim < Base

    def poi
      %w[building university school hospital mall hotel restaurant stadium bus_stop tram_stop].each do |key|
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


    ## Additional Stuff
    
    def city
      %w[city town village hamlet].each do |key|
        return @data['address'][key] if @data['address'].key?(key)
      end
      @data['display_name'].split(',').count > 3 ? @data['display_name'].split(',')[-3].strip : nil
      # return nil
    end
    
    def street
      %w[road pedestrian highway].each do |key|
        return @data['address'][key] if @data['address'].key?(key)
      end
      return nil
    end
    
    def street_number
      @data['address']['house_number']
    end
    
    def country_code
      @data['address']['country_code'].present? ? @data['address']['country_code'].to_s.upcase : nil
    end
    
    def district
      @data['address']['city_district'].present? ? @data['address']['city_district'] : nil
    end
    
    def subdistrict
      @data['address']['suburb'].present? ? @data['address']['suburb'] : nil
    end
    
    def city_code
      %w[city town village hamlet].each do |key|
        return @data['address'][key] if @data['address'].key?(key)
      end
      @data['display_name'].split(',').count > 3 ? @data['display_name'].split(',')[-3].strip : nil
    end
    
    def district_code
      @data['address']['city_district'].present? ? @data['address']['city_district'] : nil
    end
    
    def subdistrict_code
      @data['address']['suburb'].present? ? @data['address']['suburb'] : nil
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
