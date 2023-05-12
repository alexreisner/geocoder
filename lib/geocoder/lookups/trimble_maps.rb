require 'geocoder/lookups/base'
require "geocoder/results/trimble_maps"

module Geocoder::Lookup
  class TrimbleMaps < Base

    # https://developer.trimblemaps.com/restful-apis/location/single-search/single-search-api/#test-the-api-now
    def valid_region_codes
      # AF: Africa
      # AS: Asia
      # EU: Europe
      # NA: North America
      # OC: Oceania
      # SA: South America
      %w[AF AS EU NA OC SA]
    end

    def name
      "TrimbleMaps"
    end

    private # ---------------------------------------------------------------

    def base_query_url(query)
      region_code = region(query)
      if !region_code.in?(valid_region_codes)
        raise "region_code '#{region_code}' is invalid. use one of #{valid_region_codes}." \
          "https://developer.trimblemaps.com/restful-apis/location/single-search/single-search-api/#test-the-api-now"
      end
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
      query.options[:region] || query.options['region'] || configuration[:region] || "NA"
    end

    def supported_protocols
      [:https]
    end
  end
end
