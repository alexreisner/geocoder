require 'geocoder/results/base'

module Geocoder::Result
  class Maxmind2Local < Base

    def address(format = :full)
      s = state.to_s == "" ? "" : ", #{state}"
      "#{city}#{s} #{postal_code}, #{country}".sub(/^[ ,]*/, "")
    end

    def coordinates
      [@data["latitude"], @data["longitude"]]
    end

    def city
      @data["city"]
    end

    def state
      @data["subdivision"]
    end

    def state_code
      @data["subdivision_code"]
    end

    def country
      @data["country"]
    end

    def country_code
      @data["country_code"]
    end

    def postal_code
      @data["postal_code"]
    end

    def self.response_attributes
      %w[ip]
    end

    response_attributes.each do |a|
      define_method a do
        @data[a]
      end
    end
  end
end
