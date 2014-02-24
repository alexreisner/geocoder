require 'geocoder/lookups/base'
require 'geocoder/results/maxmind_local'

module Geocoder::Lookup
  class MaxmindLocal < Base

    def initialize
      begin
        gem = RUBY_PLATFORM == 'java' ? 'jgeoip' : 'geoip'
        require gem
      rescue LoadError => e
        raise 'Could not load geoip dependency. To use MaxMind Local lookup you must add the #{gem} gem to your Gemfile or have it installed in your system.'
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
      geoip_class = RUBY_PLATFORM == "java" ? JGeoIP : GeoIP
      result = geoip_class.new(configuration[:database]).city(query.to_s)
      result.nil? ? [] : [result.to_hash]
    end
  end
end
