require "geocoder/lookups/google"
require "geocoder/results/google_places_search"

module Geocoder
  module Lookup
    class GooglePlacesSearch < Google
      def name
        "Google Places Search"
      end

      def required_api_key_parts
        ["key"]
      end

      def supported_protocols
        [:https]
      end

      private

      def result_root_attr
        'candidates'
      end

      def base_query_url(query)
        "#{protocol}://maps.googleapis.com/maps/api/place/findplacefromtext/json?"
      end

      def query_url_google_params(query)
        {
          input: query.text,
          inputtype: 'textquery',
          fields: fields(query),
          language: query.language || configuration.language
        }
      end

      def fields(query)
        query_fields = query.options[:fields]
        return format_fields(query_fields) if query_fields

        default_fields
      end

      def default_fields
        legacy = %w[id reference]
        basic = %w[business_status formatted_address geometry icon name 
          photos place_id plus_code types]
        contact = %w[opening_hours]
        atmosphere = %W[price_level rating user_ratings_total]
        format_fields(legacy, basic, contact, atmosphere)
      end

      def format_fields(*fields)
        fields.flatten.join(',')
      end
    end
  end
end
