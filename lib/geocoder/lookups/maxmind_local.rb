require 'geocoder/lookups/base'
require 'geocoder/results/maxmind_local'

module Geocoder::Lookup
  class MaxmindLocal < Base

    def initialize
      begin
        require 'geoip'
      rescue LoadError => e
        raise 'Could not load geoip dependency. To use MaxMind Local lookup you must add geoip gem to your Gemfile or have it installed in your system.'
      end

      super
    end

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
      
      result = GeoIP.new(configuration[:database]).city(query.to_s)
      
      result.nil? ? [] : [result.to_hash]
    end
  end
end