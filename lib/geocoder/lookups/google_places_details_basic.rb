require "geocoder/lookups/google"
require "geocoder/results/google_places_details_basic"

module Geocoder
  module Lookup
    class GooglePlacesDetailsBasic < Google
      BASIC_FIELDS = "address_component,adr_address,alt_id,formatted_address,geometry,icon,id,name,permanently_closed,photo,place_id,scope,type,url,utc_offset,vicinity".freeze

      def name
        "Google Places Details Basic"
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
          language: query.language || configuration.language,
          fields: BASIC_FIELDS
        }
      end
    end
  end
end
