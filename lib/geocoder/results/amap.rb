require 'geocoder/results/base'

module Geocoder::Result
  class Amap < Base

    def coordinates
      @data['location'].split(",").reverse
    end

    def address
      @data['formatted_address']
    end

    def state
      province
    end

    def province
      reverse_geocode? ? address_components['province'] : @data['province']
    end

    def city
      temp_city = reverse_geocode? ? address_components['city'] : @data['city']
      temp_city.blank? ? province : temp_city
    end

    def district
      reverse_geocode? ? address_components['district'] : @data['district']
    end

    def street
      if reverse_geocode?
        if address_components["neighborhood"]["name"] != []
          return address_components["neighborhood"]["name"]
        elsif address_components["streetNumber"]["street"] != []
          return address_components["streetNumber"]["street"]
        else
          return address_components["township"]
        end
      else
        @data['street']
      end
    end

    def street_number
      reverse_geocode? ? address_components['streetNumber']["number"] : @data['number']
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

    def reverse_geocode?
      @data['addressComponent'].nil?
    end

    ##
    # Get address components of a given type. Valid types are defined in
    # Baidu's Geocoding API documentation and include (among others):
    #
    #   :business
    #   :cityCode
    #
    def self.response_attributes
      %w[roads pois roadinters]
    end

    response_attributes.each do |a|
      define_method a do
        @data[a]
      end
    end
  end
end