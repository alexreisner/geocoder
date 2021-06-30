require 'geocoder/results/base'

module Geocoder::Result
  class Amazon < Base
    def initialize(result)
      @place = result
      @data = result.to_h
      ap @data
      @data['latitude'] = latitude
      @data['longitude'] = longitude
    end

    def latitude
      @place.geometry.point[1]
    end

    def longitude
      @place.geometry.point[0]
    end

    def coordinates
      [latitude, longitude]
    end

    def address(format = :full)
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

    def postal_code
      @place.postal_code
    end

    def country
      @place.country
    end
  end
end
