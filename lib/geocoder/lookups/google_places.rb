require "geocoder/lookups/google"
require "geocoder/results/google_places"

module Geocoder
  module Lookup
    class GooglePlaces < Google
      def name
        "Google Places"
      end

      def required_api_key_parts
        ["key"]
      end

      def supported_protocols
        [:https]
      end

      def query_url(query)
        service = query.coordinates? ? 'nearbysearch' : 'textsearch'

        "#{protocol}://maps.googleapis.com/maps/api/place/#{service}/json?#{url_query_string(query)}"
      end

      private

      def results(query)
        return [] unless doc = fetch_data(query)

        case doc["status"]
          when "OK"
            return doc["results"]
          when "OVER_QUERY_LIMIT"
            raise_error(Geocoder::OverQueryLimitError) || Geocoder.log(:warn, "Google Places API error: over query limit.")
          when "REQUEST_DENIED"
            raise_error(Geocoder::RequestDenied) || Geocoder.log(:warn, "Google Places API error: request denied.")
          when "INVALID_REQUEST"
            raise_error(Geocoder::InvalidRequest) || Geocoder.log(:warn, "Google Places API error: invalid request.")
        end

        []
      end

      def query_url_google_params(query)
        params = {
            language: query.language || configuration.language
        }

        if query.coordinates?
          params[:location] = query.sanitized_text
          params[:radius] = query.options[:radius]
        else
          params[:query] = query.text
        end

        params
      end
    end
  end
end
