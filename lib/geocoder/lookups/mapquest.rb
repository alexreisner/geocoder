require 'cgi'
require 'geocoder/lookups/base'
require "geocoder/results/mapquest"

module Geocoder::Lookup
  class Mapquest < Base

    private # ---------------------------------------------------------------

    def query_url(query)
      key = Geocoder::Configuration.api_key
      domain = key ? "www" : "open"
      url = "http://#{domain}.mapquestapi.com/geocoding/v1/#{search_type(query)}?"
      url + url_query_string(query)
    end

    def search_type(query)
      query.reverse_geocode? ? "reverse" : "address"
    end

    def query_url_params(query)
      key = Geocoder::Configuration.api_key
      params = { :location => query.sanitized_text }
      if key
        params[:key] = CGI.unescape(key)
      end
      super.merge(params)
    end

    def results(query)
      return [] unless doc = fetch_data(query)
      doc["results"][0]['locations']
    end

  end
end
