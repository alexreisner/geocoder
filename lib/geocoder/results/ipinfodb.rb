require 'geocoder/results/base'

module Geocoder::Result
  class Ipinfodb < Base

    def address(format = :full)
      "#{cityName} #{zipCode}, #{countryName}".sub(/^[ ,]*/, '')
    end

    def self.response_attributes
      %w[countryCode countryName regionName cityName zipCode latitude longitude timeZone]
    end

    response_attributes.each do |attr|
      define_method attr do
        @data[attr] || ""
      end
    end
  end
end
