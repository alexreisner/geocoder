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
        use_new_places_api = query.options.fetch(:use_new_places_api, configuration.use_new_places_api)
        if use_new_places_api
          "#{protocol}://places.googleapis.com/v1/places/#{query.text}?"
        else
          "#{protocol}://maps.googleapis.com/maps/api/place/details/json?"
        end
      end

      def result_root_attr
        use_new_places_api = @query.options.fetch(:use_new_places_api, configuration.use_new_places_api)
        use_new_places_api ? nil : 'result'
      end

      def results(query)
        @query = query
        result = super(query)
        return [result] unless result.is_a? Array

        result
      end

      def fields(query)
        if query.options.has_key?(:fields)
          return format_fields(query.options[:fields])
        end

        if configuration.has_key?(:fields)
          return format_fields(configuration[:fields])
        end

        nil  # use Google Places defaults
      end

      def format_fields(*fields)
        flattened = fields.flatten.compact
        return if flattened.empty?

        flattened.join(',')
      end

      def query_url_google_params(query)
        use_new_places_api = query.options.fetch(:use_new_places_api, configuration.use_new_places_api)

        if use_new_places_api
          {
            fields: fields(query),
            languageCode: query.language || configuration.language
          }
        else
          {
            placeid: query.text,
            fields: fields(query),
            language: query.language || configuration.language
          }
        end
      end

      def parse_raw_data(raw_data)
        use_new_places_api = @query.options.fetch(:use_new_places_api, configuration.use_new_places_api)

        if use_new_places_api
          # For the new API, the top-level field is the place object itself
          super(raw_data)
        else
          super(raw_data)
        end
      end
    end
  end
end
