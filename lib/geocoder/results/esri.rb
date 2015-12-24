require 'geocoder/results/base'

module Geocoder::Result
  class Esri < Base

    def address
      address = reverse_geocode? ? 'Address' : 'Match_addr'
      attributes[address]
    end

    def city
      if !reverse_geocode? && is_city?
        attributes['PlaceName']
      else
        attributes['City']
      end
    end

    def state_code
      attributes['Region']
    end

    alias_method :state, :state_code

    def country
      country = reverse_geocode? ? "CountryCode" : "Country"
      attributes[country]
    end

    alias_method :country_code, :country

    def postal_code
      attributes['Postal']
    end

    def coordinates
      [geometry["y"], geometry["x"]]
    end

    private

    def attributes
      reverse_geocode? ? @data['address'] : @data['locations'].first['feature']['attributes']
    end

    def geometry
      reverse_geocode? ? @data["location"] : @data['locations'].first['feature']["geometry"]
    end

    def reverse_geocode?
      @data['locations'].nil?
    end

    def is_city?
      ['City', 'State Capital', 'National Capital'].include?(attributes['Type'])
    end
  end
end
