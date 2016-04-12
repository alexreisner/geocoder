require 'geocoder/results/base'

module Geocoder::Result
  class Freegeoip < Base

    def address(format = :full)
      s = state_code.to_s == "" ? "" : ", #{state_code}"
      "#{city}#{s} #{postal_code}, #{country}".sub(/^[ ,]*/, "")
    end

    def city
      @data['city']
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

    def country_code
      @data['country_code']
    end

    def postal_code
      @data['zipcode'] || @data['zip_code']
    end

    def self.response_attributes
      %w[metro_code ip]
    end

    response_attributes.each do |a|
      define_method a do
        @data[a]
      end
    end
  end
end
