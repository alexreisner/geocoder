require "geocoder/results/google"

module Geocoder
  module Result
    class GooglePlacesSearch < Google

      def types
        @data["types"] || []
      end

      def rating
        @data["rating"]
      end

      def photos
        @data["photos"]
      end
    end
  end
end
