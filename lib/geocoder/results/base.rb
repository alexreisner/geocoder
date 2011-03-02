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
      # A two-element array: [lat, lon].
      #
      def coordinates
        fail
      end

      ##
      # A string in the given format.
      #
      def address(format = :full)
        fail
      end
    end
  end
end
