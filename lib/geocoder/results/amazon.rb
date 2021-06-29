require 'geocoder/results/base'

module Geocoder::Result
  class Amazon < Base
    def initialize(result)
      @place = result
      ap @place
      @data = result.to_h
      @data['latitude'] = latitude
      @data['longitude'] = longitude
    end

    def latitude
      @place.geometry.point[0]
    end

    def longitude
      @place.geometry.point[1]
    end

    def coordinates
      [latitude, longitude]
    end

    def city
      @place.municipality
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

    def state_code
      ""
    end

  #   def address(format = :full)
  #     formatted_address
  #   end

  #   def neighborhood
  #     if neighborhood = address_components_of_type(:neighborhood).first
  #       neighborhood['long_name']
  #     end
  #   end

  #   def sub_state
  #     if state = address_components_of_type(:administrative_area_level_2).first
  #       state['long_name']
  #     end
  #   end

  #   def sub_state_code
  #     if state = address_components_of_type(:administrative_area_level_2).first
  #       state['short_name']
  #     end
  #   end

  #   def country_code
  #     if country = address_components_of_type(:country).first
  #       country['short_name']
  #     end
  #   end

  #   def postal_code
  #     if postal = address_components_of_type(:postal_code).first
  #       postal['long_name']
  #     end
  #   end

  #   def route
  #     if route = address_components_of_type(:route).first
  #       route['long_name']
  #     end
  #   end

  #   def street_number
  #     if street_number = address_components_of_type(:street_number).first
  #       street_number['long_name']
  #     end
  #   end

  #   def street_address
  #     [street_number, route].compact.join(' ')
  #   end

  #   def types
  #     @data['types']
  #   end

  #   def formatted_address
  #     @data['formatted_address']
  #   end

  #   def address_components
  #     @data['address_components']
  #   end

  #   ##
  #   # Get address components of a given type. Valid types are defined in
  #   # Google's Geocoding API documentation and include (among others):
  #   #
  #   #   :street_number
  #   #   :locality
  #   #   :neighborhood
  #   #   :route
  #   #   :postal_code
  #   #
  #   def address_components_of_type(type)
  #     address_components.select{ |c| c['types'].include?(type.to_s) }
  #   end

  #   def geometry
  #     @data['geometry']
  #   end

  #   def precision
  #     geometry['location_type'] if geometry
  #   end

  #   def partial_match
  #     @data['partial_match']
  #   end

  #   def place_id
  #     @data['place_id']
  #   end

  #   def viewport
  #     viewport = geometry['viewport'] || fail
  #     bounding_box_from viewport
  #   end

  #   def bounds
  #     bounding_box_from geometry['bounds']
  #   end

  #   private

  #   def bounding_box_from(box)
  #     return nil unless box
  #     south, west = %w(lat lng).map { |c| box['southwest'][c] }
  #     north, east = %w(lat lng).map { |c| box['northeast'][c] }
  #     [south, west, north, east]
  #   end
  end
end
