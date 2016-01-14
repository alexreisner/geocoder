require 'geocoder/results/base'

module Geocoder::Result
  class IpinfoIo < Base

    def address(format = :full)
      "#{city} #{postal_code}, #{country}".sub(/^[ ,]*/, "")
    end

    def latitude
      @data['loc'].split(',')[0]
    end

    def longitude
      @data['loc'].split(',')[1]
    end

    def city
      @data['city']
    end

    def state
      @data['region']
    end

    def state_code
      @data['region_code']
    end

    def country
      @data['country']
    end

    def postal_code
      @data['postal']
    end

    def self.response_attributes
      %w[timezone isp dma_code area_code ip asn continent_code country_code3]
    end

    response_attributes.each do |a|
      define_method a do
        @data[a]
      end
    end
  end
end
