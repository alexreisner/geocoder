require 'cgi'
require 'geocoder/lookups/base'
require "geocoder/results/mapquest"

module Geocoder::Lookup
  class Mapquest < Base

    def name
      "Mapquest"
    end

    def required_api_key_parts
      []
    end

    def query_url(query)
      key = configuration.api_key
      domain = key ? "www" : "open"
      url = "#{protocol}://#{domain}.mapquestapi.com/geocoding/v1/#{search_type(query)}?"
      url + url_query_string(query)
    end

    private # ---------------------------------------------------------------

    def search_type(query)
      query.reverse_geocode? ? "reverse" : "address"
    end

    def query_url_params(query)
      params = { :location => query.sanitized_text }
      if key = configuration.api_key
        params[:key] = CGI.unescape(key)
      end
      params.merge(super)
    end

    def results(query)
      return [] unless doc = fetch_data(query)
      doc["results"][0]['locations']
    end

  end
end
