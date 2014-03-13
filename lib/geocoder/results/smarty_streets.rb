require 'geocoder/lookups/base'

module Geocoder::Result
  class SmartyStreets < Base
    def coordinates
      %w(latitude longitude).map do |i|
        (zipcode_result? && zipcodes.first[i]) || metadata[i]
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
      components['state_abbreviation'] || city_states.first['state']
    end

    def state_code
      if cs = city_states.first
        cs['state_abbreviation']
      else
        state
      end
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
      components['city_name'] || city_states.first['city']
    end

    def zipcode
      components['zipcode'] || zipcodes.first['zipcode']
    end
    alias_method :postal_code, :zipcode

    def zip4
      components['plus4_code']
    end
    alias_method :postal_code_extended, :zip4

    def fips
      metadata['county_fips'] || zipcodes.first['county_fips']
    end

    def zipcode_result?
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
      private m
    end

    [
      :components,
      :metadata,
      :analysis
    ].each do |m|
      define_method(m) do
        @data[m.to_s] || {}
      end
      private m
    end

    [
      :city_states,
      :zipcodes
    ].each do |m|
      define_method(m) do
        @data[m.to_s] || []
      end
      private m
    end
  end
end
