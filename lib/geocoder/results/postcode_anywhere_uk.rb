require 'geocoder/results/base'

module Geocoder::Result
  class PostcodeAnywhereUk < Base

    def coordinates
      [@data['Latitude'].to_f, @data['Longitude'].to_f]
    end

    def blank_result
      ''
    end
    alias_method :state, :blank_result
    alias_method :state_code, :blank_result
    alias_method :postal_code, :blank_result

    def address
      [@data['Location'], @data['OsGrid']].join(', ')
    end

    def city
      # is this too big a jump to assume that the API always
      # returns a City, County as the last elements?
      city = @data['Location'].split(',')[-2] || blank_result
      city.strip
    end

    def country
      'United Kingdom'
    end

    def country_code
      'UK'
    end
  end
end
