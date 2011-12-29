require 'geocoder/lookups/base'
require "geocoder/results/bing"

module Geocoder::Lookup
  class Bing < Base

    def map_link_url(coordinates)
      "http://www.bing.com/maps/default.aspx?cp=#{coordinates.join('~')}"
    end

    private # ---------------------------------------------------------------

    def results(query, options = {})
      return [] unless doc = fetch_data(query, options)

      if doc['statusDescription'] == "OK"
        return doc['resourceSets'].first['estimatedTotal'] > 0 ? doc['resourceSets'].first['resources'] : []
      else
        warn "Bing Geocoding API error: #{doc['statusCode']} (#{doc['statusDescription']})."
        return []
      end
    end

    def query_url(query, options = {})
      params = {:key => Geocoder::Configuration.api_key}
      params[:query] = query unless options[:reverse]

      base_url = "http://dev.virtualearth.net/REST/v1/Locations"
      url_tail = options[:reverse] ? "/#{query}?" : "?"
      base_url + url_tail + hash_to_query(params)
    end
  end
end
