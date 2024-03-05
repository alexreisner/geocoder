require 'geocoder/results/google_new'

module Geocoder::Result
  class GooglePlacesDetailsNew < GoogleNew
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

