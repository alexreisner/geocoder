require 'geocoder/results/base'

module Geocoder::Result
  class Mapbox < Base

    def coordinates
      @data["geometry"]["coordinates"].reverse.map(&:to_f)
    end

    def place_name
      @data['text']
    end

    def street
      @data['properties']['address']
    end

    def city
      @data['context'].map { |c| c['text'] if c['id'] =~ /place/ }.compact.first
    end

    def state
      @data['context'].map { |c| c['text'] if c['id'] =~ /region/ }.compact.first
    end

    alias_method :state_code, :state

    def postal_code
      @data['context'].map { |c| c['text'] if c['id'] =~ /postcode/ }.compact.first
    end

    def country
      @data['context'].map { |c| c['text'] if c['id'] =~ /country/ }.compact.first
    end

    alias_method :country_code, :country

    def neighborhood
      @data['context'].map { |c| c['text'] if c['id'] =~ /neighborhood/ }.compact.first
    end

    def address
      [place_name, street, city, state, postal_code, country].compact.join(", ")
    end
  end
end

