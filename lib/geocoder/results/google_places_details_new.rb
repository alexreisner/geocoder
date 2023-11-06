require 'geocoder/results/google'

module Geocoder::Result
  class GooglePlacesDetails < GoogleNew
    def types
      @data['types'] || []
    end

    def primary_type
      @data['primaryType']
    end

    def reviews
      @data['reviews'] || []
    end

    def rating
      @data['rating']
    end

    def rating_count
      @data['userRatingCount']
    end

    def phone_number
      @data['internationalPhoneNumber']
    end

    def website
      @data['websiteUri']
    end

    def photos
      @data['photos'] || []
    end
  end
end

