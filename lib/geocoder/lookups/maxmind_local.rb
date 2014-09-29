require 'ipaddr'
require 'json'
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

    def cache_key(query)
      "maxmind_local/geolite_city/#{query.text}"
    end

    private

    def results(query)
      key    = cache_key(query)
      result = cache ? cache[key] : nil
      return deserialize(result) if result

      return [] if query.loopback_ip_address?

      addr = IPAddr.new(query.text).to_i
      block = MaxmindGeoliteCityBlock
        .includes(:location)
        .where("start_ip_num <= ? AND end_ip_num >= ?", addr, addr)
        .first

      result     = block ? block.to_result : []
      cache[key] = serialize(result) if cache

      result
    end

    def serialize(result)
      JSON.generate(result)
    end

    def deserialize(result)
      JSON.parse(result, symbolize_names: true)
    end
  end

  class MaxmindGeoliteCityBlock < ActiveRecord::Base
    belongs_to :location, class_name: "MaxmindGeoliteCityLocation", foreign_key: :loc_id, primary_key: :loc_id

    def to_result
      location ? location.to_result : []
    end
  end

  class MaxmindGeoliteCityLocation < ActiveRecord::Base
    self.table_name  = :maxmind_geolite_city_location
    self.primary_key = :loc_id

    has_many :blocks, class_name: "MaxmindGeoliteCityBlock", foreign_key: :loc_id

    def to_result
      [{
        country_name: country,
        region_name: region,
        city_name: city,
        latitude: latitude,
        longitude: longitude
      }]
    end
  end
end
