require 'geocoder/results/base'

module Geocoder::Result
  class Ipgeolocation < Base

    def address(format = :full)
      s = region_code.empty? ? "" : ", #{region_code}"
      "#{city}#{s} #{zip}, #{country_name}".sub(/^[ ,]*/, "")
    end

    def state
      @data['region_name']
    end

    def state_code
      @data['region_code']
    end

    def country
      @data['country_name']
    end

    def postal_code
      @data['zip'] || @data['zipcode'] || @data['zip_code']
    end

    def self.response_attributes
      [
          ['ip', ''],
          ['hostname', ''],
          ['continent_code', ''],
          ['continent_name', ''],
          ['country_code2', ''],
          ['country_code3', ''],
          ['country_name', ''],
          ['country_capital',''],
          ['district',''],
          ['state_prov',''],
          ['city', ''],
          ['zipcode', ''],
          ['latitude', 0],
          ['longitude', 0],
          ['time_zone', {}],
          ['currency', {}]
      ]
    end

    response_attributes.each do |attr, default|
      define_method attr do
        @data[attr] || default
      end
    end
  end
end