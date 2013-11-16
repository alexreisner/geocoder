require 'geocoder/results/base'

module Geocoder::Result
  class Baidu < Base

    def coordinates
      ['lat', 'lng'].map{ |i| @data['location'][i] }
    end

    def address
      @data['formatted_address']
    end

    def state
      province
    end
    
    def province
      @data['addressComponent']['province']
    end

    def city
      @data['addressComponent']['city']
    end

    def district
      @data['addressComponent']['district']
    end

    def street
      @data['addressComponent']['street']
    end

    def street_number
      @data['addressComponent']['street_number']
    end

    def formatted_address
      @data['formatted_address']
    end

    def address_components
      @data['addressComponent']
    end

    def state_code
      ""
    end

    def postal_code
      ""
    end

    def country
      "China"
    end

    def country_code
      "CN"
    end

    ##
    # Get address components of a given type. Valid types are defined in
    # Baidu's Geocoding API documentation and include (among others):
    #
    #   :business
    #   :cityCode
    #
    def self.response_attributes
      %w[business cityCode]
    end

    response_attributes.each do |a|
      define_method a do
        @data[a]
      end
    end
  end
end
