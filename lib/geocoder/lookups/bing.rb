require 'geocoder/lookups/base'
require "geocoder/results/bing"

module Geocoder::Lookup
  class Bing < Base

    def map_link_url(coordinates)
      "http://www.bing.com/maps/default.aspx?cp=#{coordinates.join('~')}"
    end

    private # ---------------------------------------------------------------

    def results(query)
      return [] unless doc = fetch_data(query)

      if doc['statusDescription'] == "OK"
        return doc['resourceSets'].first['estimatedTotal'] > 0 ? doc['resourceSets'].first['resources'] : []
      else
        warn "Bing Geocoding API error: #{doc['statusCode']} (#{doc['statusDescription']})."
        return []
      end
    end

    def query_url_params(query)
      super.merge(
        :key => Geocoder::Configuration.api_key,
        :query => query.reverse_geocode? ? nil : query.sanitized_text
      )
    end

    def query_url(query)
      "http://dev.virtualearth.net/REST/v1/Locations" +
        (query.reverse_geocode? ? "/#{query.sanitized_text}?" : "?") +
        url_query_string(query)
    end
  end
end
