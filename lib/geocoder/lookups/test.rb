require 'geocoder/lookups/base'
require 'geocoder/results/test'

module Geocoder
  module Lookup
    class Test < Base

      def self.add_stub(query, results)
        stubs[query] = results
      end

      def self.read_stub(query)
        stubs.fetch(query) { raise ArgumentError, "unknown stub request #{query}" }
      end

      def self.stubs
        @stubs ||= {}
      end

      def self.reset
        @stubs = {}
      end

      private

      def results(query, reverse = false)
        Geocoder::Lookup::Test.read_stub(query)
      end

    end
  end
end
