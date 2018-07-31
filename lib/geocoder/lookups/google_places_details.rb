require "geocoder/lookups/google"
require "geocoder/results/google_places_details"

module Geocoder
  module Lookup
    class GooglePlacesDetails < Google
      def name
        "Google Places Details"
      end

      def required_api_key_parts
        ["key"]
      end

      def supported_protocols
        [:https]
      end

      private

      def base_query_url(query)
        "#{protocol}://maps.googleapis.com/maps/api/place/details/json?"
      end

      def results(query)
        return [] unless doc = fetch_data(query)

        case doc["status"]
        when "OK"
          return [doc["result"]]
        when "OVER_QUERY_LIMIT"
          raise_error(Geocoder::OverQueryLimitError) || Geocoder.log(:warn, "Google Places Details API error: over query limit.")
        when "REQUEST_DENIED"
          raise_error(Geocoder::RequestDenied) || Geocoder.log(:warn, "Google Places Details API error: request denied.")
        when "INVALID_REQUEST"
          raise_error(Geocoder::InvalidRequest) || Geocoder.log(:warn, "Google Places Details API error: invalid request.")
        end

        []
      end

      def query_url_google_params(query)
        {
          placeid: query.text,
          language: query.language || configuration.language
        }
      end
    end
  end
end
