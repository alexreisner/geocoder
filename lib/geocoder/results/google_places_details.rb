require "geocoder/results/base"

module Geocoder::Result
  class GooglePlacesDetails < Base

    def coordinates
      if @data.dig('location', 'latitude') && @data.dig('location', 'longitude')
        [@data.dig('location', 'latitude'), @data.dig('location', 'longitude')]
      elsif @data.dig('geometry', 'location', 'lat') && @data.dig('geometry', 'location', 'lng')
        [@data.dig('geometry', 'location', 'lat'), @data.dig('geometry', 'location', 'lng')]
      else
        []
      end
    end

    def address
      formatted_address
    end

    def formatted_address
      @data['formattedAddress'] || @data['formatted_address']
    end

    def name
      if @data.dig('displayName', 'text')
        @data.dig('displayName', 'text')
      else
        @data['name']
      end
    end

    def place_id
      @data['id'] || @data['place_id']
    end

    def types
      @data['types'] || []
    end

    def website
      @data['websiteUri'] || @data['website']
    end

    def url
      @data['url'] || @data['googleMapsUri']
    end

    def rating
      @data['rating']
    end

    def reviews
      @data['reviews'] || []
    end

    def photos
      @data['photos'] || []
    end

    def phone_number
      @data['international_phone_number'] || @data['internationalPhoneNumber']
    end

    def user_ratings_total
      @data['userRatingsTotal'] || @data['user_ratings_total']
    end
    alias_method :rating_count, :user_ratings_total

    def business_status
      @data['business_status'] || @data['businessStatus']
    end

    def price_level
      @data['price_level'] || @data['priceLevel']
    end

    def open_hours
      if @data['regularOpeningHours'] && @data['regularOpeningHours']['periods']
        @data['regularOpeningHours']['periods']
      elsif @data['opening_hours'] && @data['opening_hours']['periods']
        @data['opening_hours']['periods']
      else
        []
      end
    end

    def open_now
      if @data['regularOpeningHours']
        @data.dig('regularOpeningHours', 'openNow')
      elsif @data['opening_hours']
        @data.dig('opening_hours', 'open_now')
      end
    end

    def permanently_closed?
      business_status == 'CLOSED_PERMANENTLY' || business_status == 'PERMANENTLY_CLOSED'
    end

    def address_components
      @data['addressComponents'] || @data['address_components'] || []
    end

    def street_number
      address_component('street_number', 'short_name')
    end

    def route
      address_component('route', 'long_name')
    end

    def street_address
      [street_number, route].compact.join(' ')
    end

    def city
      address_component('locality', 'long_name')
    end

    def state
      address_component('administrative_area_level_1', 'long_name')
    end

    def state_code
      address_component('administrative_area_level_1', 'short_name')
    end

    def country
      address_component('country', 'long_name')
    end

    def country_code
      address_component('country', 'short_name')
    end

    def postal_code
      address_component('postal_code', 'long_name')
    end

    def neighborhood
      address_component('neighborhood', 'long_name')
    end

    ##
    # Get address components of a given type. Type can be a String or an Array
    # of Strings. Returns an Array of components.
    #
    def address_components_of_type(type)
      return [] if address_components.empty?

      address_components.select do |c|
        types = c['types'] || []
        types.any?{ |t| type.to_s === t }
      end
    end

    def address_component(component_type, value_type)
      components = address_components_of_type(component_type)
      return nil if components.empty?

      component = components.first

      if value_type == 'short_name'
        component['shortName'] || component['short_name']
      else
        component['longName'] || component['long_name']
      end
    end
  end
end
