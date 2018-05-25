require 'geocoder/results/base'

module Geocoder::Result
  class PostcodesIo < Base
    def coordinates
      [latitude, longitude]
    end

    def latitude
      @data['latitude'].to_f
    end

    def longitude
      @data['longitude'].to_f
    end

    def quality
      @data['quality']
    end

    def postal_code
      @data['postcode']
    end
    alias address postal_code

    def city
      @data['admin_ward']
    end

    def county
      @data['admin_county']
    end
    alias state county

    def state_code
      @data['codes']['admin_county']
    end

    def country
      'United Kingdom'
    end

    def country_code
      'UK'
    end
  end
end
