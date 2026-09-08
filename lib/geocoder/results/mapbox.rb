require 'geocoder/results/base'

module Geocoder::Result
  class Mapbox < Base

    def coordinates
      data['geometry']['coordinates'].reverse.map(&:to_f)
    end

    def place_name
      properties['full_address'] || properties['name']
    end

    alias_method :address, :place_name

    def street
      context_part('address', 'name') || context_part('street', 'name')
    end

    def city
      context_part('place', 'name')
    end

    def county
      context_part('district', 'name')
    end

    def state
      context_part('region', 'name')
    end

    def state_code
      context_part('region', 'region_code')
    end

    def postal_code
      context_part('postcode', 'name')
    end

    def country
      context_part('country', 'name')
    end

    def country_code
      value = context_part('country', 'country_code')
      value.upcase unless value.nil?
    end

    def neighborhood
      context_part('neighborhood', 'name')
    end

    # rooftop / parcel / point / interpolated / approximate / intersection
    def precision
      (properties['coordinates'] || {})['accuracy']
    end

    private

    def properties
      data['properties'] || {}
    end

    def context
      properties['context'] || {}
    end

    def context_part(name, key)
      (context[name] || {})[key]
    end
  end
end
