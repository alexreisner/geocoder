require 'geocoder/results/base'

module Geocoder::Result
  class Geocodio < Base
    def number
      address_components["number"]
    end

    def street
      address_components["street"]
    end

    def suffix
      address_components["suffix"]
    end

    def state
      address_components["state"]
    end
    alias_method :state_code, :state

    def zip
      address_components["zip"]
    end
    alias_method :postal_code, :zip

    def country
      "United States" # Geocodio only supports the US
    end

    def country_code
      "US" # Geocodio only supports the US
    end

    def city
      address_components["city"]
    end

    def postdirectional
      address_components["postdirectional"]
    end

    def location
      @data['location']
    end

    def coordinates
      ['lat', 'lng'].map{ |i| location[i] } if location
    end

    def accuracy
      @data['accuracy'].to_f if @data.key?('accuracy')
    end

    def formatted_address(format = :full)
      @data['formatted_address']
    end
    alias_method :address, :formatted_address

    private

    def address_components
      @data['address_components'] || {}
    end
  end
end
