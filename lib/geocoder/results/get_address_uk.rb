require 'geocoder/results/base'

module Geocoder::Result
  class GetAddressUk < Base

    def coordinates
      [@data['Latitude'].to_f, @data['Longitude'].to_f]
    end
    alias_method :to_coordinates, :coordinates

    def blank_result
      ''
    end
    alias_method :postal_code, :blank_result
    alias_method :os_grid, :blank_result

    def address
      @data['Addresses'].first
    end

    def city
      city = @data['Addresses'].first.split(',')[-2] || blank_result
      city.strip
    end

    def state
      state = @data['Addresses'].first.split(',')[-1] || blank_result
      state.strip
    end
    alias_method :state_code, :state

    # This is a UK only API; all results are UK specific, hence omitted from API response.
    def country
      'United Kingdom'
    end

    def country_code
      'UK'
    end

    def self.response_attributes
      %w[Latitude Longitude Addresses]
    end

    response_attributes.each do |a|
      define_method a do
        @data[a]
      end
    end
  end
end
