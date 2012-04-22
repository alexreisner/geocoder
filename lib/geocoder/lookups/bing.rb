require 'geocoder/lookups/base'
require "geocoder/results/bing"

module Geocoder::Lookup
  class Bing < Base

    def map_link_url(coordinates)
      "http://www.bing.com/maps/default.aspx?cp=#{coordinates.join('~')}"
    end

    private # ---------------------------------------------------------------

    def results(query, reverse_or_options = false)
      return [] unless doc = fetch_data(query, reverse_or_options)

      if doc['statusDescription'] == "OK"
        return doc['resourceSets'].first['estimatedTotal'] > 0 ? doc['resourceSets'].first['resources'] : []
      else
        warn "Bing Geocoding API error: #{doc['statusCode']} (#{doc['statusDescription']})."
        return []
      end
    end

    def query_url(query, reverse_or_options = false)
      reverse, options = extract_reverse_and_options(reverse_or_options)

      params = {:key => Geocoder::Configuration.api_key}
      params[:query] = query unless reverse

      base_url = "http://dev.virtualearth.net/REST/v1/Locations"
      url_tail = reverse ? "/#{query}?" : "?"
      base_url + url_tail + hash_to_query(params)
    end
  end
end
