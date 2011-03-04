require 'geocoder/results/base'

module Geocoder::Result
  class Freegeoip < Base

    def address(format = :full)
      "#{city}#{', ' + region_code unless region_code == ''} #{zipcode}, #{country_name}"
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
