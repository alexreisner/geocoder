require "geocoder/results/google"

module Geocoder
  module Result
    class GooglePlacesDetailsBasic < Google
      def place_id
        @data["place_id"]
      end

      def types
        @data["types"] || []
      end

      def photos
        @data["photos"]
      end
    end
  end
end
