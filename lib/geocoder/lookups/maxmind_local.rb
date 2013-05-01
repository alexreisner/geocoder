require 'geocoder/lookups/base'
require 'geocoder/results/maxmind_local'
require 'geoip'

module Geocoder::Lookup
  class MaxmindLocal < Base

    def name
      "MaxMind Local"
    end

    def required_api_key_parts
      []
    end

    private

    def results(query)
      if configuration[:database].nil?
        raise(
          Geocoder::ConfigurationError,
          "When using MaxMind Database you MUST specify the path: " +
          "Geocoder.configure(:maxmind_local => {:database => ...}), "
        )
      end

      [GeoIP.new(configuration[:database]).city(query.to_s)]
    end
  end
end