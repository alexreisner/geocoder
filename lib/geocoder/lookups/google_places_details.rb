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

      def result_root_attr
        'result'
      end

      def results(query)
        result = super(query)
        return [result] unless result.is_a? Array

        result
      end

      def query_url_google_params(query)
        {
          placeid: query.text,
          fields: fields(query),
          language: query.language || configuration.language
        }
      end

      def fields(query)
        query_fields = query.options[:fields]
        return format_fields(query_fields) if query_fields

        default_fields
      end

      # https://developers.google.com/maps/documentation/places/web-service/details#fields
      def default_fields
        legacy = %w[permanently_closed]
        basic = %w[address_component adr_address business_status formatted_address geometry icon name
          photo place_id plus_code type url utc_offset vicinity]
        contact = %w[formatted_phone_number international_phone_number opening_hours website]
        atmosphere = %W[price_level rating review user_ratings_total]
        format_fields(legacy, basic, contact, atmosphere)
      end

      def format_fields(*fields)
        fields.flatten.join(',')
      end
    end
  end
end
