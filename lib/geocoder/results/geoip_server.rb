require 'geocoder/results/base'

module Geocoder::Result
  class GeoipServer < Base

    def address(format = :full)
      "#{city}, #{state_code} #{postal_code}, #{country}".sub(/^[ ,]*/, "")
    end

    def coordinates
      [@data['lat'].to_f, @data['lng'].to_f]
    end

    def city
      @data['city']
    end

    def state
      state_code
    end

    def state_code
      @data['region']
    end

    def country
      @data['country']
    end

    def country_code
      @data['country_code']
    end

    def postal_code
      @data['postal_code']
    end

    def self.response_attributes
      %w[dma_code ip ip_lookup area_code country_code_long continent timezone]
    end

    response_attributes.each do |a|
      define_method a do
        @data[a]
      end
    end
  end
end
