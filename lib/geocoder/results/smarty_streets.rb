#
# Results from the zipcode endpoint are completely different
# from the address endpoint. KeyError rescues below will
# return the appropriate value for each one.
# ---

require 'geocoder/lookups/base'

module Geocoder::Result
  class SmartyStreets < Base
    def coordinates
      %w(latitude longitude).map{|i| (zipcode_result? && zipcodes.first[i]) ||
                                      metadata[i] }
    end

    def address
      begin
        line_2 = delivery_line_2
      rescue KeyError
        line_2 = ''
      end
      "#{delivery_line_1} #{line_2} #{last_line}".strip.gsub("  ", " ") || nil
    end

    def state
      components['state_abbreviation']
    rescue KeyError
      city_states.first['state']
    end

    def state_code
      city_states.first['state_abbreviation']
    rescue KeyError
      state
    end

    def country
      # SmartyStreets returns results for USA only
      "US"
    end
    alias_method :country_code, :country

## Extra methods not in base.rb ------------------------

    def street
      components['street_name']
    rescue KeyError
      nil
    end

    def city
      components['city_name']
    rescue KeyError
      city_states.first['city']
    end

    def zipcode
      components['zipcode']
    rescue KeyError
      zipcodes.first['zipcode']
    end
    alias_method :postal_code, :zipcode

    def zip4
      components['plus4_code']
    rescue KeyError
      nil
    end
    alias_method :postal_code_extended, :zip4

    def fips
      metadata['county_fips']
    rescue KeyError
      zipcodes.first['county_fips']
    end

    def zipcode_result?
      zipcodes.any? rescue false
    end

    # References to `components`, `metadata`, `city_states`, `zipcodes` land here.
    def method_missing(meth, *args, &block)
      @data.fetch(meth.to_s)
    end
  end
end
