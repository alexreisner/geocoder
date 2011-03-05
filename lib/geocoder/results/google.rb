require 'geocoder/results/base'

module Geocoder::Result
  class Google < Base

    def coordinates
      ['lat', 'lng'].map{ |i| geometry['location'][i] }
    end

    def address(format = :full)
      formatted_address
    end

    def city
      address_components_of_type(:locality).first['long_name']
    end

    def country
      address_components_of_type(:country).first['long_name']
    end

    def country_code
      address_components_of_type(:country).first['short_name']
    end

    def postal_code
      address_components_of_type(:postal_code).first['long_name']
    end

    def types
      @data['types']
    end

    def formatted_address
      @data['formatted_address']
    end

    def address_components
      @data['address_components']
    end

    ##
    # Get address components of a given type. Valid types are defined in
    # Google's Geocoding API documentation and include (among others):
    #
    #   :street_number
    #   :locality
    #   :neighborhood
    #   :route
    #   :postal_code
    #
    def address_components_of_type(type)
      address_components.select{ |c| c['types'].include?(type.to_s) }
    end

    def geometry
      @data['geometry']
    end
  end
end
