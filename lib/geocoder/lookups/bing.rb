require 'geocoder/lookups/base'
require "geocoder/results/bing"

module Geocoder::Lookup
  class Bing < Base

    def name
      "Bing"
    end

    def map_link_url(coordinates)
      "http://www.bing.com/maps/default.aspx?cp=#{coordinates.join('~')}"
    end

    def required_api_key_parts
      ["key"]
    end

    def query_url(query)
      "#{protocol}://dev.virtualearth.net/REST/v1/Locations" +
        (query.reverse_geocode? ? "/#{query.sanitized_text}?" : "?") +
        url_query_string(query)
    end

    private # ---------------------------------------------------------------

    def results(query)
      return [] unless doc = fetch_data(query)

      if doc['statusCode'] == 200
        return doc['resourceSets'].first['estimatedTotal'] > 0 ? doc['resourceSets'].first['resources'] : []
      elsif doc['statusCode'] == 401 and doc["authenticationResultCode"] == "InvalidCredentials"
        raise_error(Geocoder::InvalidApiKey) || warn("Invalid Bing API key.")
      else
        warn "Bing Geocoding API error: #{doc['statusCode']} (#{doc['statusDescription']})."
      end
      return []
    end

    def query_url_params(query)
      {
        :key => configuration.api_key,
        :query => query.reverse_geocode? ? nil : query.sanitized_text
      }.merge(super)
    end
  end
end
