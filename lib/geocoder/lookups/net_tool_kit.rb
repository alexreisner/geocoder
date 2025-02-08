require 'geocoder/lookups/base'
require 'geocoder/results/net_tool_kit'

module Geocoder::Lookup
  class NetToolKit < Base

    def name
      'NetToolKit'
    end

    def supported_protocols
      [:https]
    end

    private # ---------------------------------------------------------------

    def base_query_url(query)
      "#{protocol}://api.nettoolkit.com/v1/geo/#{search_type(query)}?version=2&"
    end

    def search_type(query)
      query.reverse_geocode? ? 'reverse-geocodes' : 'geocodes'
    end

    def query_url_params(query)
      params = { address: query.sanitized_text }

      [:provider].each do |option|
        unless (option_value = query.options[option]).nil?
          params[option] = option_value
        end
      end

      params.merge(super)
    end

    def results(query)
      return [] unless doc = fetch_data(query)
      return doc['results'] if doc['code'] == 1000 || doc['code'] == 1001

      messages = doc['message']
      case doc['code']
      when 2002, 2003, 2004, 2005
        raise_error(Geocoder::ServiceUnavailable, messages) ||
          Geocoder.log(:warn, "NetToolKit Geocoding API error: #{messages}")
      when 3000
        raise_error(Geocoder::RequestDenied, messages) ||
          Geocoder.log(:warn, "NetToolKit Geocoding API error: #{messages}")
      when 3001, 3003
        raise_error(Geocoder::OverQueryLimitError, messages) ||
          Geocoder.log(:warn, "NetToolKit Geocoding API error: #{messages}")
      when 3002
        raise_error(Geocoder::InvalidApiKey, messages) ||
          Geocoder.log(:warn, "NetToolKit Geocoding API error: #{messages}")
      when 4000, 4001, 4002
        raise_error(Geocoder::InvalidRequest, messages) ||
          Geocoder.log(:warn, "NetToolKit Geocoding API error: #{messages}")
      else
        raise_error(Geocoder::Error, messages) ||
          Geocoder.log(:warn, "NetToolKit Geocoding API error: #{messages}")
      end
    end

  end
end
