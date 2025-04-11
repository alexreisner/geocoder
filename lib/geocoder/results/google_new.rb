require 'geocoder/results/base'

module Geocoder::Result
  class GoogleNew < Base
    def coordinates
      if @data['location']
        [@data['location']['latitude'], @data['location']['longitude']]
      else
        []
      end
    end

    def address(format = :full)
      formatted_address
    end

    def formatted_address
      @data['formattedAddress']
    end

    def street_address
      address_components_of_type(:route).first['longText'] if address_components_of_type(:route).first
    end

    def city
      if entity = address_components_of_type(:locality).first
        return entity['longText']
      end

      # If no locality, try:
      [:sublocality, :administrative_area_level_3, :administrative_area_level_2].each do |t|
        if entity = address_components_of_type(t).first
          return entity['longText']
        end
      end

      return nil # no city found
    end

    def state
      if entity = address_components_of_type(:administrative_area_level_1).first
        entity['longText']
      end
    end

    def state_code
      if entity = address_components_of_type(:administrative_area_level_1).first
        entity['shortText']
      end
    end

    def country
      if entity = address_components_of_type(:country).first
        entity['longText']
      end
    end

    def country_code
      if entity = address_components_of_type(:country).first
        entity['shortText']
      end
    end

    def postal_code
      if entity = address_components_of_type(:postal_code).first
        entity['longText']
      end
    end

    def types
      @data['types'] || []
    end

    def place_id
      @data['id']
    end

    def name
      @data['displayName'] ? @data['displayName']['text'] : nil
    end
    alias_method :display_name, :name

    def vicinity
      @data['shortFormattedAddress']
    end

    def rating
      @data['rating']
    end

    def rating_count
      @data['userRatingCount']
    end

    def reviews
      @data['reviews'] || []
    end

    def photos
      @data['photos'] || []
    end

    def website
      @data['websiteUri']
    end

    def phone_number
      @data['internationalPhoneNumber']
    end

    def primary_type
      @data['primaryType']
    end

    def address_components_of_type(type)
      @data['addressComponents'].to_a.select{ |c| c['types'].include?(type.to_s) }
    end
  end
end
