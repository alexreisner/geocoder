require 'ipaddr'
require 'geocoder/lookups/base'
require 'geocoder/results/maxmind_local'

module Geocoder::Lookup
  class MaxmindLocal < Base

    def initialize
      if !configuration[:file].nil?
        begin
          gem = RUBY_PLATFORM == 'java' ? 'jgeoip' : 'geoip'
          require gem
        rescue LoadError
          raise "Could not load geoip dependency. To use MaxMind Local lookup you must add the #{gem} gem to your Gemfile or have it installed in your system."
        end
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
      if !configuration[:file].nil?
        geoip_class = RUBY_PLATFORM == "java" ? JGeoIP : GeoIP
        result = geoip_class.new(configuration[:file]).city(query.to_s)
        result.nil? ? [] : [result.to_hash]
      elsif configuration[:package] == :city
        addr = IPAddr.new(query.text).to_i
        q = "SELECT l.country, l.region, l.city
          FROM maxmind_geolite_city_location l JOIN maxmind_geolite_city_blocks b USING (locId)
          WHERE b.startIpNum <= #{addr} AND #{addr} <= b.endIpNum"
        if r = ActiveRecord::Base.connection.execute(q).first
          [Hash[*[:country_name, :region_name, :city_name].zip(r).flatten]]
        end
      elsif configuration[:package] == :country
        addr = IPAddr.new(query.text).to_i
        q = "SELECT country, country_code
          FROM maxmind_geolite_country
          WHERE startIpNum <= #{addr} AND #{addr} <= endIpNum"
        if r = ActiveRecord::Base.connection.execute(q).first
          [Hash[*[:country_name, :country_code].zip(r).flatten]]
        end
      end
    end
  end
end
