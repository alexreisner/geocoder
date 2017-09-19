require 'geocoder/lookups/nominatim'
require "geocoder/results/location_iq"

module Geocoder::Lookup
  class LocationIq < Nominatim
    def name
      "LocationIq"
    end

    def required_api_key_parts
      ["api_key"]
    end
    
    def query_url(query)
      method = query.reverse_geocode? ? "reverse" : "search"
      "#{protocol}://locationiq.org/v1/#{method}.php?key=#{configuration.api_key}&" + url_query_string(query)
    end

    private

    def results(query)
      return [] unless doc = fetch_data(query)

      if !doc.is_a?(Array)
        case doc['error']
        when "Invalid key"
          raise_error(Geocoder::InvalidApiKey, doc['error'])
        when "Key not active - Please write to contact@unwiredlabs.com"
          raise_error(Geocoder::RequestDenied, doc['error'])
        when "Rate Limited"
          raise_error(Geocoder::OverQueryLimitError, doc['error'])
        when "Unknown error - Please try again after some time"
          raise_error(Geocoder::InvalidRequest, doc['error'])
        end
      end

      doc.is_a?(Array) ? doc : [doc]
    end
  end
end
