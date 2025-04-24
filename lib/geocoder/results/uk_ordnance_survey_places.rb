require 'geocoder/results/base'
require 'easting_northing'

module Geocoder::Result
  class UkOrdnanceSurveyPlaces < Base

    def coordinates
      @coordinates ||= Geocoder::EastingNorthing.new(
        easting: data['X_COORDINATE'],
        northing: data['Y_COORDINATE'],
      ).lat_lng
    end

    def city
      data['POST_TOWN']
    end

    def county
      data['DEPENDENT_LOCALITY']
    end
    alias state county

    def county_code
      ''
    end
    alias state_code county_code

    def province
      {
        'E' => 'England',
        'W' => 'Wales',
        'S' => 'Scotland',
        'N' => 'Northern Ireland',
        'L' => 'Channel Islands',
        'M' => 'Isle of Man',
        'J' => ''
      }[data['COUNTRY_CODE']]
    end

    def province_code
      data['COUNTRY_CODE']
    end

    def postal_code
      data['POSTCODE']
    end

    def country
      'United Kingdom'
    end

    def country_code
      'UK'
    end
  end
end
