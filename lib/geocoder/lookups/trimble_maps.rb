require 'geocoder/lookups/base'
require "geocoder/results/trimble_maps"

module Geocoder::Lookup
  class TrimbleMaps < Base

    def name
      "TrimbleMaps"
    end

    private # ---------------------------------------------------------------

    def base_query_url(query)
      region_code = region(query)
      "#{protocol}://singlesearch.alk.com/#{region_code}/api/search?query=#{query.sanitized_text}&"
    end

    def results(query)
      return [] unless data = fetch_data(query)
      if data['Locations']
        data['Locations']
      else
        []
      end
    end

    def query_url_params(query)
      {authToken: configuration.api_key}.merge(super(query))
    end

    def region(query)
      # https://developer.trimblemaps.com/restful-apis/location/single-search/single-search-api/#test-the-api-now
      # North America (NA)
      # Europe (EU)
      # Asia (AS)
      # Africa (AF)
      # South America (SA)
      # Oceania (OC)
      query.options[:region] || query.options['region'] || configuration[:region] || "NA"
    end

    def supported_protocols
      [:https]
    end
  end
end
