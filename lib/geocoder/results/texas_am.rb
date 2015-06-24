require 'geocoder/results/base'

module Geocoder::Result
  class TexasAm < Base

    def latitude
      @data['OutputGeocodes'][0]['OutputGeocode']['Latitude'].to_f unless reverse_geocode?
    end

    def longitude
      @data['OutputGeocodes'][0]['OutputGeocode']['Longitude'].to_f unless reverse_geocode?
    end

    def coordinates
      [latitude, longitude]
    end

    def city
      address_components['City']
    end

    def street
      address_components['StreetAddress']
    end

    def state
      address_components['State']
    end

    def zip
      address_components['Zip']
    end

    # Texas A&M does not provide this data so assume only USA
    def country
      'United States'
    end

    # Texas A&M does not provide this data so assume only USA
    def country_code
      'US'
    end

    alias_method :state_code, :state
    alias_method :province, :state
    alias_method :province_code, :state
    alias_method :postal_code, :zip

    def address
      [street, city, state, postal_code].reject{|s| s.length == 0 }.join(', ')
    end

    def reverse_geocode?
      @data.has_key?('StreetAddresses')
    end

    private

    def address_components
      reverse_geocode? ? @data['StreetAddresses'][0] : @data['InputAddress']
    end

  end
end