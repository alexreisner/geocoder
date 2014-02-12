require 'geocoder/results/base'

module Geocoder::Result
  class Geocodefarm < Base

    def address
      @data['ADDRESS']['address_returned']
    end

    def address_provided
      @data['ADDRESS']['address_provided']
    end

    def latitude
        @data['COORDINATES']['latitude'].to_f
      end

    def longitude
      @data['COORDINATES']['longitude'].to_f
    end

    def coordinates
      [latitude, longitude]
    end

    def quality
      @data['ADDRESS']['accuracy']
    end

    def self.response_attributes
      %w[]
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
