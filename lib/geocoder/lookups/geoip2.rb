require 'geocoder/lookups/base'
require 'geocoder/results/geoip2'

module Geocoder
  module Lookup
    class Geoip2 < Base
      def initialize
        unless configuration[:file].nil?
          begin
            @gem_name = configuration[:lib] || 'maxminddb'
            require @gem_name
          rescue LoadError
            raise "Could not load Maxmind DB dependency. To use the GeoIP2 lookup you must add the #{@gem_name} gem to your Gemfile or have it installed in your system."
          end

          if @gem_name == 'hive_geoip2'
            @mmdb = Hive::GeoIP2.new(configuration[:file].to_s)
          else
            @mmdb = MaxMindDB.new(configuration[:file].to_s)
          end
        end
        super
      end

      def name
        'GeoIP2'
      end

      def required_api_key_parts
        []
      end

      private

      def results(query)
        return [] unless configuration[:file]

        result = @mmdb.lookup(query.to_s)
        result.nil? ? [] : [result]
      end
    end
  end
end
