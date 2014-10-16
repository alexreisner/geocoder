require 'geocoder/lookups/base'
require 'geocoder/results/geolite2'

module Geocoder
  module Lookup
    class Geolite2 < Base
      def initialize
        unless configuration[:file].nil?
          begin
            gem_name = 'hive_geoip2'
            require gem_name
          rescue LoadError
            raise "Could not load maxminddb dependency. To use GeoLite2 lookup you must add the #{gem_name} gem to your Gemfile or have it installed in your system."
          end
        end
        super
      end

      def name
        'GeoLite2'
      end

      def required_api_key_parts
        []
      end

      private

      def results(query)
        return [] unless configuration[:file]
        result = Hive::GeoIP2.lookup(query.to_s, configuration[:file].to_s)
        result.nil? ? [] : [result]
      end
    end
  end
end
