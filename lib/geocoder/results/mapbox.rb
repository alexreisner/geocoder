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
      data_part('place') || context_part('place')
    end

    def state
      data_part('region') || context_part('region')
    end

    def state_code
      if id_matches_name?(data['id'], 'region')
        value = data['properties']['short_code']
      else
        value = context_part('region', 'short_code')
      end

      value.split('-').last unless value.nil?
    end

    def postal_code
      data_part('postcode') || context_part('postcode')
    end

    def country
      data_part('country') || context_part('country')
    end

    def country_code
      if id_matches_name?(data['id'], 'country')
        value = data['properties']['short_code']
      else
        value = context_part('country', 'short_code')
      end

      value.upcase unless value.nil?
    end

    def neighborhood
      data_part('neighborhood') || context_part('neighborhood')
    end

    def address
      data['place_name']
    end

    private

    def id_matches_name?(id, name)
      id =~ Regexp.new(name)
    end

    def data_part(name)
      data['text'] if id_matches_name?(data['id'], name)
    end

    def context_part(name, key = 'text')
      (context.detect { |c| id_matches_name?(c['id'], name) } || {})[key]
    end

    def context
      Array(data['context'])
    end
  end
end

