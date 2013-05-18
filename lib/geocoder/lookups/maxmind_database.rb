require 'geocoder/lookups/base'
require 'geocoder/results/maxmind_database'
require 'geoip'

module Geocoder::Lookup
  class MaxmindDatabase < Base

    def name
      "MaxMind Database"
    end

    def required_api_key_parts
      ["path"]
    end

    private

    def results(query)
      unless configuration[:path]
        raise(
          Geocoder::ConfigurationError,
          "When using MaxMind Database you MUST specify the path: " +
          "Geocoder.configure(:path => ...), "
        )
      end

      [GeoIP.new(configuration.path).city(query.to_s)]
    end
  end
end
