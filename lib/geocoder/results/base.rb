module Geocoder
  module Result
    class Base
      attr_accessor :data

      ##
      # Takes a hash of result data from a parsed Google result document.
      #
      def initialize(data)
        @data = data
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

      def country
        fail
      end

      def country_code
        fail
      end

      def [](i)
        if i == 0
          warn "DEPRECATION WARNING: You called '[0]' on a Geocoder::Result object. Geocoder.search(...) now returns a single result instead of an array so this is no longer necessary. This warning will be removed and an error will result in geocoder 1.0."
        elsif i.is_a?(Fixnum)
          warn "DEPRECATION WARNING: You tried to access a Geocoder result but Geocoder.search(...) now returns a single result instead of an array. This warning will be removed and an error will result in geocoder 1.0."
        end
        self
      end

      def first
        warn "DEPRECATION WARNING: You called '.first' on a Geocoder::Result object. Geocoder.search(...) now returns a single result instead of an array so this is no longer necessary. This warning will be removed and an error will result in geocoder 1.0."
        self
      end
    end
  end
end
