require 'ipaddr'
require 'geocoder/lookups/base'
require 'geocoder/results/maxmind2_local'

module Geocoder::Lookup
  class Maxmind2Local < Base

    def initialize
      if !configuration[:file].nil?
        begin
          require 'geoip2'
        rescue LoadError
          raise "Could not load geoip2 dependency. To use MaxMind Local lookup you must add the geoip2 gem to your Gemfile or have it installed in your system."
        end
      else
        raise "File must be specified when loading GeoIP2 database."
      end
      super
    end

    def name
      "MaxMind2 Local"
    end

    def required_api_key_parts
      []
    end

    private

    def results(query)
      GeoIP2::file(configuration[:file])
      result = GeoIP2::locate(query.to_s, 'en')
      (result.nil? || !result) ? [] : [result.to_hash]
    end

    def format_result(query, attr_names)
      if r = ActiveRecord::Base.connection.execute(query).first
        r = r.values if r.is_a?(Hash) # some db adapters return Hash, some Array
        [Hash[*attr_names.zip(r).flatten]]
      else
        []
      end
    end
  end
end
