require "geocoder/results/base"

module Geocoder::Result
  class GooglePlacesSearch < Base
    def coordinates
      [@data.dig('geometry', 'location', 'lat'), @data.dig('geometry', 'location', 'lng')]
    end

    def place_id
      @data['place_id']
    end

    def types
      @data['types'] || []
    end

    def formatted_address
      @data['formatted_address']
    end
    alias_method :address, :formatted_address

    def name
      @data["displayName"] ? @data["displayName"]["text"] : @data["name"]
    end

    def rating
      @data["rating"]
    end

    def photos
      @data["photos"]
    end

    def short_formatted_address
      @data["vicinity"] || @data["shortFormattedAddress"]
    end
    alias_method :vicinity, :short_formatted_address

    def price_level
      @data["price_level"] || @data["priceLevel"]
    end

    def rating_count
      @data["user_ratings_total"] || @data["userRatingsTotal"]
    end

    def attributions
      @data["html_attributions"] || @data["attributions"]
    end

    def business_status
      @data["business_status"] || @data["businessStatus"]
    end

    def city
      ""
    end

    def state
      ""
    end

    def state_code
      ""
    end

    def province
      ""
    end

    def province_code
      ""
    end

    def postal_code
      ""
    end

    def country
      ""
    end

    def country_code
      ""
    end

    # Access to viewport
    def viewport
      return nil unless @data["viewport"]
      [
        @data["viewport"]["southwest"]["lat"],
        @data["viewport"]["southwest"]["lng"],
        @data["viewport"]["northeast"]["lat"],
        @data["viewport"]["northeast"]["lng"]
      ]
    end
  end
end
