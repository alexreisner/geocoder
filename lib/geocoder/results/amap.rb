# -*- encoding: utf-8 -*-
require 'geocoder/results/base'

module Geocoder::Result
  class Amap < Base
    def coordinates
      location = @data['location'] || @data['roadinters'].try(:[], 'location')
      location.to_s.split(",").map(&:to_f)
    end

    def street
      if address_components['neighborhood']['name'] != []
        return address_components['neighborhood']['name']
      elsif address_components['township'] != []
        return address_components['township']
      else
        return @data['street'] || address_components['streetNumber'].try(:[], 'street')
      end
    end
    
    def address
      formatted_address
    end

    def formatted_address
      @data['formatted_address']
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

    def street_number
      @data['number'] || address_components['streetNumber'].try(:[], 'number')
    end

    def state
      province
    end

    def address_components
      @data['addressComponent'] || @data
    end

    def country
      "China"
    end

    def country_code
      "CN"
    end

    def self.response_attributes
      %w[state_code postal_code]
    end

    response_attributes.each do |a|
      define_method a do
        ''
      end
    end
  end
end