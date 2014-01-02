require 'geocoder/results/base'

module Geocoder::Result
  class Baidu < Base

    def coordinates
      from_ip_geocoding? ? [content['point']['y'], content['point']['x']] : ['lat', 'lng'].map{ |i| @data['location'][i] }
    end

    def address
      from_ip_geocoding? ? @data['address'] : @data['formatted_address']
    end

    def state
      province
    end
    
    def province
      from_ip_geocoding? ? content['province'] : @data['addressComponent']['province']
    end

    def city
      from_ip_geocoding? ? content['city'] : @data['addressComponent']['city']
    end

    def district
      from_ip_geocoding? ? content['district'] : @data['addressComponent']['district']
    end

    def street
      from_ip_geocoding? ? content['street'] : @data['addressComponent']['street']
    end

    def street_number
      from_ip_geocoding? ? content['street_number'] : @data['addressComponent']['street_number']
    end

    def formatted_address
      @data['formatted_address']
    end

    def content
      @data['content']
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

    def from_ip_geocoding?
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
