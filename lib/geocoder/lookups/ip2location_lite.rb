require 'geocoder/lookups/base'
require 'geocoder/results/ip2location_lite'

module Geocoder
  module Lookup
    class Ip2locationLite < Base
      attr_reader :gem_name

      def initialize
        unless configuration[:file].nil?
          begin
            @gem_name = 'ip2location_ruby'
            require @gem_name
          rescue LoadError
            raise "Could not load IP2Location DB dependency. To use the IP2LocationLite lookup you must add the #{@gem_name} gem to your Gemfile or have it installed in your system."
          end
        end
        super
      end

      def name
        'IP2LocationLite'
      end

      def required_api_key_parts
        []
      end

      private

      def results(query)
        return [] unless configuration[:file]

        i2l = Ip2location.new.open(configuration[:file].to_s)
        result = i2l.get_all(query.to_s)
        result.nil? ? [] : [result]
      end
    end
  end
end