require 'geocoder/results/base'

module Geocoder::Result
  class Mapbox < Base

    def coordinates
      data['geometry']['coordinates'].reverse.map(&:to_f)
    end

    def place_name
      data['text']
    end

    def street
      data['properties']['address']
    end

    def city
      context_part('place')
    end

    def state
      context_part('region')
    end

    alias_method :state_code, :state

    def postal_code
      context_part('postcode')
    end

    def country
      context_part('country')
    end

    alias_method :country_code, :country

    def neighborhood
      context_part('neighborhood')
    end

    def address
      [place_name, street, city, state, postal_code, country].compact.join(', ')
    end

    private

    def context_part(name)
      context.map { |c| c['text'] if c['id'] =~ Regexp.new(name) }.compact.first
    end

    def context
      Array(data['context'])
    end
  end
end

