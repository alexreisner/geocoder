require 'geocoder/results/base'

module Geocoder::Result
  class Ip2locationLite < Base

    def address(format = :full)
      "#{city} #{zipcode}, #{country_long}".sub(/^[ ,]*/, '')
    end

    def self.response_attributes
      %w[country_short country_long region city latitude longitude
        isp domain netspeed areacode iddcode timezone zipcode weatherstationname
        weatherstationcode mcc mnc mobilebrand elevation usagetype]
    end

    response_attributes.each do |attr|
      define_method attr do
        @data[attr] || ""
      end
    end
  end
end
