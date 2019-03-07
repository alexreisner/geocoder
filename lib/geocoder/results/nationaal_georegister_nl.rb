require 'geocoder/results/base'

module Geocoder::Result
  class NationaalGeoregisterNl < Base

    def response_attributes
      @data
    end

    def coordinates
      lat, lng = @data['geometrie_ll'][6..-2].split(' ')

      [lat, lng]
    end

    def formatted_address
      @data['weergavenaam']
    end

    alias_method :address, :formatted_address

    def province
      @data['provincienaam']
    end

    alias_method :state, :province

    def city
      @data['woonplaatsnaam']
    end

    def district
      @data['gemeentenaam']
    end

    def street
      @data['straatnaam']
    end

    def street_number
      @data['huis_nlt']
    end

    def address_components
      @data
    end

    def state_code
      @data['provinciecode']
    end

    def postal_code
      @data['postcode']
    end

    def country
      "Netherlands"
    end

    def country_code
      "NL"
    end
  end
end
