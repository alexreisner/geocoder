require 'cgi'
require 'geocoder/lookups/base'
require "geocoder/results/mapquest"

module Geocoder::Lookup
  class Mapquest < Base

    def name
      "Mapquest"
    end

    def required_api_key_parts
      ["key"]
    end

    def query_url(query)
      domain = configuration[:licensed] ? "www" : "open"
      version = configuration[:version] || 1
      url = "#{protocol}://#{domain}.mapquestapi.com/geocoding/v#{version}/#{search_type(query)}?"
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

    # http://www.mapquestapi.com/geocoding/status_codes.html
    # http://open.mapquestapi.com/geocoding/status_codes.html
    def results(query)
      return [] unless doc = fetch_data(query)
      return doc["results"][0]['locations'] if doc['info']['statuscode'] == 0 # A successful geocode call

      messages = doc['info']['messages'].join

      case doc['info']['statuscode']
      when 400 # Error with input
        raise_error(Geocoder::InvalidRequest, messages) ||
          warn("Mapquest Geocoding API error: #{messages}")
      when 403 # Key related error
        raise_error(Geocoder::InvalidApiKey, messages) ||
          warn("Mapquest Geocoding API error: #{messages}")
      when 500 # Unknown error
        raise_error(Geocoder::Error, messages) ||
          warn("Mapquest Geocoding API error: #{messages}")
      end
    end

  end
end
