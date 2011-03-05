require 'geocoder/results/base'

module Geocoder::Result
  class Freegeoip < Base

    def address(format = :full)
      "#{city}#{', ' + region_code unless region_code == ''} #{postal_code}, #{country}"
    end

    def city
      @data['city']
    end

    def country
      @data['country_name']
    end

    def country_code
      @data['country_code']
    end

    def postal_code
      @data['zipcode']
    end

    def self.response_attributes
      %w[city region_code region_name metrocode
        zipcode country_name country_code ip]
    end

    response_attributes.each do |a|
      define_method a do
        @data[a]
      end
    end
  end
end
