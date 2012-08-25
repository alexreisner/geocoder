require 'geocoder/results/base'

module Geocoder::Result
  class Dummy < Base

    def initialize(data = {})
      @data = data.dup
    end

    def address(format = :full)
      @data['address']
    end

    def city
      @data['city']
    end

    def state_code
      @data['state']
    end

    alias_method :state, :state_code

    def country
      @data['country']
    end

    alias_method :country_code, :country

    def postal_code
      @data['postal_code']
    end

    def latitude
      @data['latitude']
    end

    def longitude
      @data['longitude']
    end

    def coordinates
      @data['coordinates'] || [latitude.to_f, longitude.to_f]
    end

    def address_data
      @data.dup
    end
  end
end
