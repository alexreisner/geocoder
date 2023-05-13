require 'geocoder/lookups/base'
require "geocoder/results/trimble_maps"
require 'cgi' unless defined?(CGI) && defined?(CGI.escape)

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
      if !valid_region_codes.include?(region_code)
        raise "region_code '#{region_code}' is invalid. use one of #{valid_region_codes}." \
          "https://developer.trimblemaps.com/restful-apis/location/single-search/single-search-api/#test-the-api-now"
      end

      "#{protocol}://singlesearch.alk.com/#{region_code}/api/search?"
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
      if query.reverse_geocode?
        lat,lon = query.coordinates
        escaped_query = "#{CGI.escape(lat)},#{CGI.escape(lon)}"
      else
        escaped_query = CGI.escape(query.text.to_s)
      end

      {
        authToken: configuration.api_key,
        query: escaped_query
      }.merge(super(query))
    end

    def region(query)
      query.options[:region] || query.options['region'] || configuration[:region] || "NA"
    end

    def supported_protocols
      [:https]
    end
  end
end
