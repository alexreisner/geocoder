require "geocoder/results/google"

module Geocoder
  module Result
    class GooglePlaces < Google
      def place_id
        @data['place_id']
      end

      def name
        @data['name']
      end

      def vicinity
        @data['vicinity']
      end
    end
  end
end
