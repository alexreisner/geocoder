require "geocoder/results/google"

module Geocoder
  module Result
    class GooglePlacesDetails < Google
      def place_id
        @data["place_id"] || @data["id"]
      end

      def types
        @data["types"] || []
      end

      def reviews
        @data["reviews"] || []
      end

      def rating
        @data["rating"]
      end

      def rating_count
        @data["user_ratings_total"] || @data["userRatingsTotal"]
      end

      def phone_number
        @data["international_phone_number"] || @data["internationalPhoneNumber"]
      end

      def website
        @data["website"] || @data["websiteUri"]
      end

      def photos
        @data["photos"]
      end

      def display_name
        @data["displayName"] ? @data["displayName"]["text"] : @data["name"]
      end
      alias_method :name, :display_name

      def formatted_address
        @data["formatted_address"] || @data["formattedAddress"]
      end

      def short_formatted_address
        @data["vicinity"] || @data["shortFormattedAddress"]
      end
      alias_method :vicinity, :short_formatted_address

      def price_level
        @data["price_level"] || @data["priceLevel"]
      end

      def opening_hours
        @data["opening_hours"] || @data["regularOpeningHours"]
      end

      def attributions
        @data["html_attributions"] || @data["attributions"]
      end

      def business_status
        @data["business_status"] || @data["businessStatus"]
      end

      # Support both legacy geometry and new location format
      def coordinates
        if @data['geometry'] && @data['geometry']['location']
          [@data['geometry']['location']['lat'], @data['geometry']['location']['lng']]
        elsif @data['location']
          [@data['location']['latitude'], @data['location']['longitude']]
        else
          []
        end
      end
    end
  end
end
