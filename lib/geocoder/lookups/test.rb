require 'geocoder/lookups/base'
require 'geocoder/results/test'

module Geocoder
  module Lookup
    class Test < Base

      private

      def results(query, reverse = false)
        Geocoder::Configuration.read_stub(query)
      end

    end
  end
end
