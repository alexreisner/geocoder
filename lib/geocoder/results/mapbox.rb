require 'geocoder/results/base'

module Geocoder::Result
  class Mapbox < Base

    def latitude
      @latitude ||= @data["geometry"]["coordinates"].first.to_f
    end

    def longitude
      @longitude ||= @data["geometry"]["coordinates"].last.to_f
    end

    def coordinates
      [latitude, longitude]
    end

    def city
      @data['context'].map {|c| c['text'] if c['id'] =~ /place/ }.compact.first || ''
    end

    def street
      @data['properties']['address'] || ''
    end

    def state
      @data['context'].map {|c| c['text'] if c['id'] =~ /region/ }.compact.first || ''
    end

    alias_method :state_code, :state

    def postal_code
      @data['context'].map {|c| c['text'] if c['id'] =~ /postcode/ }.compact.first  || ''
    end

    def country
      @data['context'].map {|c| c['text'] if c['id'] =~ /country/ }.compact.first || ''
    end

    def country_code
      country
    end

    def place_name
      @data['text'] || ''
    end

    def address
      [place_name, street, city, state, postal_code, country].reject{|s| s.length == 0 }.join(", ")
    end
  end
end

