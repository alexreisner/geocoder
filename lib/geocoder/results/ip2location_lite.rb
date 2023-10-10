require 'geocoder/results/base'

module Geocoder::Result
  class Ip2locationLite < Base

    def coordinates
      [@data[:latitude], @data[:longitude]]
    end

    def city
      @data[:city]
    end

    def state
      @data[:region]
    end

    def state_code
      "" # Not available in Maxmind's database
    end

    def country
      @data[:country_long]
    end

    def country_code
      @data[:country_short]
    end

    def postal_code
      @data[:zipcode]
    end

    def self.response_attributes
      %w[country_short country_long region latitude longitude isp
        domain netspeed areacode iddcode timezone zipcode weatherstationname
        weatherstationcode mcc mnc mobilebrand elevation usagetype addresstype
        category district asn as]
    end

    response_attributes.each do |a|
      define_method a do
        @data[a] || ""
      end
    end
  end
end