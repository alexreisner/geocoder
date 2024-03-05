require 'geocoder/results/base'

module Geocoder::Result
  class GoogleNew < Base

    def coordinates
      ['latitude', 'longitude'].map{ |i| @data['location'][i] }
    end

    def address(format = :full)
      formatted_address
    end

    def neighborhood
      if neighborhood = address_components_of_type(:neighborhood).first
        neighborhood['longText']
      end
    end

    def city
      fields = [:locality, :sublocality,
        :administrative_area_level_3,
        :administrative_area_level_2]
      fields.each do |f|
        if entity = address_components_of_type(f).first
          return entity['longText']
        end
      end

      return nil # no appropriate components found
    end

    def state
      if state = address_components_of_type(:administrative_area_level_1).first
        state['longText']
      end
    end

    def state_code
      if state = address_components_of_type(:administrative_area_level_1).first
        state['shortText']
      end
    end

    def sub_state
      if state = address_components_of_type(:administrative_area_level_2).first
        state['longText']
      end
    end

    def sub_state_code
      if state = address_components_of_type(:administrative_area_level_2).first
        state['shortText']
      end
    end

    def country
      if country = address_components_of_type(:country).first
        country['longText']
      end
    end

    def country_code
      if country = address_components_of_type(:country).first
        country['shortText']
      end
    end

    def postal_code
      if postal = address_components_of_type(:postal_code).first
        postal['longText']
      end
    end

    def route
      if route = address_components_of_type(:route).first
        route['longText']
      end
    end

    def street_number
      if street_number = address_components_of_type(:street_number).first
        street_number['longText']
      end
    end

    def street_address
      [street_number, route].compact.join(' ')
    end

    def types
      @data['types']
    end

    def formatted_address
      @data['formattedAddress']
    end

    def address_components
      @data['addressComponents']
    end

    ##
    # Get address components of a given type. Valid types are defined in
    # Google's Geocoding API documentation and include (among others):
    #
    #   :street_number
    #   :locality
    #   :neighborhood
    #   :route
    #   :postal_code
    #
    def address_components_of_type(type)
      address_components.select{ |c| c['types'].include?(type.to_s) }
    end

    def place_id
      @data['id']
    end
  end
end

