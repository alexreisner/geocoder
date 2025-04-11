require "geocoder/results/google"

module Geocoder
  module Result
    class GooglePlacesSearch < Google
      def place_id
        @data["place_id"] || @data["id"]
      end

      def types
        @data["types"] || []
      end

      def rating
        @data["rating"]
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

      def rating_count
        @data["user_ratings_total"] || @data["userRatingsTotal"]
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

      # Access to complex nested structures
      def location
        return nil unless @data["location"]
        [@data["location"]["lat"], @data["location"]["lng"]]
      end

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
end
