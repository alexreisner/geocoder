require 'geocoder/results/base'

module Geocoder::Result
  class AmazonLocationService < Base
    def initialize(result)
      @place = result.place
      super
    end

    def coordinates
      [@place.geometry.point[1], @place.geometry.point[0]]
    end

    def address
      @place.label
    end

    def neighborhood
      @place.neighborhood
    end

    def route
      @place.street
    end

    def city
      @place.municipality || @place.sub_region
    end

    def state
      @place.region
    end

    def state_code
      @place.region
    end

    def province
      @place.region
    end

    def province_code
      @place.region
    end

    def postal_code
      @place.postal_code
    end

    def country
      @place.country
    end

    def country_code
      @place.country
    end

    def place_id
      data.place_id if data.respond_to?(:place_id)
    end
  end
end
