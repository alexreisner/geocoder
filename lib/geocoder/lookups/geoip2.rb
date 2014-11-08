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
        if @gem_name == 'hive_geoip2'
          result = Hive::GeoIP2.lookup(query.to_s, configuration[:file].to_s)
        else
          result = MaxMindDB.new(configuration[:file].to_s).lookup(query.to_s)
        end
        result.nil? ? [] : [result]
      end
    end
  end
end
