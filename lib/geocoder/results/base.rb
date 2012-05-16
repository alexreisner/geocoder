module Geocoder
  module Result
    class Base
      attr_accessor :data, :cache_hit

      ##
      # Takes a hash of result data from a parsed Google result document.
      #
      def initialize(data)
        @data = data
        @cache_hit = nil
      end

      ##
      # A string in the given format.
      #
      def address(format = :full)
        fail
      end

      ##
      # A two-element array: [lat, lon].
      #
      def coordinates
        [@data['latitude'].to_f, @data['longitude'].to_f]
      end

      def latitude
        coordinates[0]
      end

      def longitude
        coordinates[1]
      end

      def state
        fail
      end

      def province
        state
      end

      def state_code
        fail
      end

      def province_code
        state_code
      end

      def country
        fail
      end

      def country_code
        fail
      end
    end
  end
end
