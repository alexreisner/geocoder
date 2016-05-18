require 'geocoder/results/base'

module Geocoder::Result
  class Esri < Base

    def id
      @data['attributes']['ResultID']
    end

    def address
      attributes['Match_addr'] || attributes['Address']
    end

    def city
      if !reverse_geocode? && is_city?
        place_name
      else
        attributes['City']
      end
    end

    def state_code
      attributes['Region']
    end

    alias_method :state, :state_code

    def country
      attributes['Country'] || attributes['CountryCode']
    end

    alias_method :country_code, :country

    def postal_code
      attributes['Postal']
    end

    def place_name
      place_name_key = reverse_geocode? ? "Address" : "PlaceName"
      attributes[place_name_key]
    end

    def place_type
      attributes['Type'] || 'Address'
    end

    def coordinates
      [geometry["y"], geometry["x"]]
    end

    def viewport
      north = attributes['Ymax']
      south = attributes['Ymin']
      east = attributes['Xmax']
      west = attributes['Xmin']
      [south, west, north, east]
    end

    private

    def attributes
      if @data['locations'] 
        # standard geocode results
        @data['locations'].first['feature']['attributes']
      elsif @data['attributes']
        # a result from batch geocoding
        @data['attributes']
      else
        # reverse geocoding result
        @data['address']
      end
    end

    def geometry
      if @data['locations']
        # standard geocode results
        @data['locations'].first['feature']["geometry"]
      elsif @data['location']
        # a result from batch geocoding or reverse geocoding
        @data['location']
      else
        # no result returned from batch geocoding
        {}
      end
    end

    def reverse_geocode?
      @data['locations'].nil? and @data['attributes'].nil?
    end

    def is_city?
      ['City', 'State Capital', 'National Capital'].include?(place_type)
    end
  end
end
