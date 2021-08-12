require 'geocoder/lookups/base'
require "geocoder/results/net_tool_kit"

module Geocoder::Lookup
  class NetToolKit < Base

    def name
      "NetToolKit"
    end

    def required_api_key_parts
      [:http_headers]
    end
    
    def supported_protocols
      [:https]
    end

    private # ---------------------------------------------------------------

    def base_query_url(query)
      "#{protocol}://api.nettoolkit.com/v1/geo/geocodes#{search_type(query)}?"
    end

    def search_type(query)
      query.reverse_geocode? ? "reverse-geocodes" : "geocodes"
    end

    def query_url_params(query)
      params = { :address => query.sanitized_text }
      
      [:provider].each do |option|
        unless (option_value = query.options[option]).nil?
          params[option] = option_value
        end
      end
      
      params.merge(super)
    end

    def results(query)
      return [] unless doc = fetch_data(query)
      return doc["results"] if doc['code'] == 1000
      
      messages = doc['message']
      case doc['code']
      when 4001 # Error with input
        raise_error(Geocoder::InvalidRequest, messages) ||
          Geocoder.log(:warn, "NetToolKit Geocoding API error: #{messages}")
      when 3002 # Key related error
        raise_error(Geocoder::InvalidApiKey, messages) ||
          Geocoder.log(:warn, "NetToolKit Geocoding API error: #{messages}")
      else
        raise_error(Geocoder::Error, messages) ||
          Geocoder.log(:warn, "NetToolKit Geocoding API error: #{messages}")
      end
    end

  end
end
