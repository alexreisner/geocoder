require 'geocoder/results/base'

module Geocoder
  module Result
    class Test < Base

      def address
        @data['address']
      end

      def state
        @data['state']
      end

      def state_code
        @data['state_code']
      end

      def country
        @data['country']
      end

      def country_code
        @data['country_code']
      end

    end
  end
end
