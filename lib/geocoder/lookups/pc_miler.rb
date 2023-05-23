require 'geocoder/lookups/base'
require "geocoder/results/pc_miler"
require 'cgi' unless defined?(CGI) && defined?(CGI.escape)

module Geocoder::Lookup
  class PcMiler < Base

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
      "PCMiler"
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

    def check_response_for_errors!(response)
      if response.code.to_i == 403
        raise_error(Geocoder::RequestDenied) ||
          Geocoder.log(:warn, "Geocoding API error: 403 API key does not exist")
      else
        super(response)
      end
    end

    def supported_protocols
      [:https]
    end
  end
end
