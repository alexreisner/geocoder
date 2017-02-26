require 'geocoder/lookups/base'

module Geocoder::Result
  class SmartyStreets < Base
    def coordinates
      result = %w(latitude longitude).map do |i|
        zipcode_endpoint? ? zipcodes.first[i] : metadata[i]
      end

      if result.compact.empty?
        nil
      else
        result
      end
    end

    def address
      [
        delivery_line_1,
        delivery_line_2,
        last_line
      ].select{ |i| i.to_s != "" }.join(" ")
    end

    def state
      zipcode_endpoint? ?
        city_states.first['state'] :
        components['state_abbreviation']
    end

    def state_code
      zipcode_endpoint? ?
        city_states.first['state_abbreviation'] :
        components['state_abbreviation']
    end

    def country
      # SmartyStreets returns results for USA only
      "United States"
    end

    def country_code
      # SmartyStreets returns results for USA only
      "US"
    end

    ## Extra methods not in base.rb ------------------------

    def street
      components['street_name']
    end

    def city
      zipcode_endpoint? ?
        city_states.first['city'] :
        components['city_name']
    end

    def zipcode
      zipcode_endpoint? ?
        zipcodes.first['zipcode'] :
        components['zipcode']
    end
    alias_method :postal_code, :zipcode

    def zip4
      components['plus4_code']
    end
    alias_method :postal_code_extended, :zip4

    def fips
      zipcode_endpoint? ?
        zipcodes.first['county_fips'] :
        metadata['county_fips']
    end

    def zipcode_endpoint?
      zipcodes.any?
    end

    [
      :delivery_line_1,
      :delivery_line_2,
      :last_line,
      :delivery_point_barcode,
      :addressee
    ].each do |m|
      define_method(m) do
        @data[m.to_s] || ''
      end
    end

    [
      :components,
      :metadata,
      :analysis
    ].each do |m|
      define_method(m) do
        @data[m.to_s] || {}
      end
    end

    [
      :city_states,
      :zipcodes
    ].each do |m|
      define_method(m) do
        @data[m.to_s] || []
      end
    end
  end
end
