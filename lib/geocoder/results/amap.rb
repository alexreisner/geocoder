require 'geocoder/results/base'

module Geocoder::Result
  class Amap < Base

    def coordinates
      @data.first['location'].split(",").reverse
    end

    def address
      @data.first['formatted_address']
    end

    def state
      province
    end

    def province
      address_components['province']
    end

    def city
      address_components['city'] == [] ? province : address_components["city"]
    end

    def district
      address_components['district']
    end

    def street
      if address_components["neighborhood"]["name"] != []
        return address_components["neighborhood"]["name"]
      elsif address_components["streetNumber"]["street"] != []
        return address_components["streetNumber"]["street"]
      else
        return address_components["township"]
      end
    end

    def street_number
      address_components['streetNumber']["number"]
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
      %w[roads pois roadinters]
    end

    response_attributes.each do |a|
      define_method a do
        @data[a]
      end
    end
  end
end