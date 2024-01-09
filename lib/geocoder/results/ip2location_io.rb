require 'geocoder/results/base'

module Geocoder::Result
  class Ip2locationIo < Base

    def address(format = :full)
      "#{city_name} #{zip_code}, #{country_name}".sub(/^[ ,]*/, '')
    end

    def self.response_attributes
      %w[ip country_code country_name region_name city_name latitude longitude
        zip_code time_zone asn as is_proxy]
    end

    response_attributes.each do |attr|
      define_method attr do
        @data[attr] || ""
      end
    end
  end
end
