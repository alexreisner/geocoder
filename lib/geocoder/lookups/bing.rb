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
      base_url(query) + url_query_string(query)
    end

    private # ---------------------------------------------------------------

    def base_url(query)
      url = "#{protocol}://dev.virtualearth.net/REST/v1/Locations"

      if !query.reverse_geocode?
        if r = query.options[:region]
          url << "/#{r}"
        end
        # use the more forgiving 'unstructured' query format to allow special
        # chars, newlines, brackets, typos.
        url + "?q=" + URI.escape(query.sanitized_text.strip) + "&"
      else
        url + "/#{URI.escape(query.sanitized_text.strip)}?"
      end
    end

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
        key: configuration.api_key
      }.merge(super)
    end
  end
end
