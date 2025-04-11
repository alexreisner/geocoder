require "geocoder/lookups/google"
require "geocoder/results/google_places_details"
require 'logger'

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
          # For the new API, always construct the URL assuming the place ID doesn't have the 'places/' prefix
          # Place IDs should be URL-encoded to handle special characters
          encoded_place_id = URI.encode_www_form_component(query.text)
          url = "#{protocol}://places.googleapis.com/v1/places/#{encoded_place_id}?"
          Geocoder.log(:debug, "New Places API URL: #{url}")
          url
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

      # Override query_url for the new API format
      def query_url(query)
        use_new_places_api = query.options.fetch(:use_new_places_api, configuration.use_new_places_api)
        @query = query

        url = if use_new_places_api
          base_query_url(query) + url_query_string(query)
        else
          super(query)
        end

        Geocoder.log(:debug, "Final URL: #{url}")
        url
      end

      # Override for the new API to avoid including the API key in URL params
      def query_url_params(query)
        use_new_places_api = query.options.fetch(:use_new_places_api, configuration.use_new_places_api)

        if use_new_places_api
          # For the new API, don't include the API key in URL params
          # It will be sent in the X-Goog-Api-Key header
          query_url_google_params(query).merge(super.except(:key))
        else
          # For legacy API, use the original implementation
          super
        end
      end

      # Override make_api_request to add the API key as a header for the new API
      def make_api_request(query)
        use_new_places_api = query.options.fetch(:use_new_places_api, configuration.use_new_places_api)
        @query = query

        if use_new_places_api
          uri = URI.parse(query_url(query))

          Geocoder.log(:debug, "Making request to: #{uri.to_s}")

          response = http_client.start(uri.host, uri.port, use_ssl: use_ssl?) do |client|
            req = Net::HTTP::Get.new(uri.request_uri)
            req["X-Goog-Api-Key"] = configuration.api_key

            # Add the required FieldMask header
            # Fields need to be formatted correctly for the API
            req["X-Goog-FieldMask"] = "id,displayName.text,formattedAddress,location,types,websiteUri,rating,userRatingsTotal,priceLevel,businessStatus,regularOpeningHours,photos,internationalPhoneNumber"

            Geocoder.log(:debug, "Request headers: #{req.to_hash.inspect}")

            response = client.request(req)
            Geocoder.log(:debug, "Response code: #{response.code}")
            Geocoder.log(:debug, "Response body: #{response.body[0..500]}...")
            response
          end
          response
        else
          super(query)
        end
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

      # Default fields to request if not specified
      def default_fields_for_mask
        # For new API, use properly formatted field paths with dot notation
        # This is required by the Places API (New)
        [
          "id",
          "displayName.text",
          "formattedAddress",
          "location",
          "types",
          "websiteUri",
          "rating",
          "userRatingsTotal",
          "priceLevel",
          "businessStatus",
          "regularOpeningHours",
          "photos",
          "internationalPhoneNumber"
        ].join(',')
      end

      def format_fields(*fields)
        flattened = fields.flatten.compact
        return if flattened.empty?

        flattened.join(',')
      end

      def query_url_google_params(query)
        use_new_places_api = query.options.fetch(:use_new_places_api, configuration.use_new_places_api)

        if use_new_places_api
          params = {}
          params[:languageCode] = query.language || configuration.language if query.language || configuration.language
          params
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

        # Log the first part of the response for debugging
        if raw_data.is_a?(String) && raw_data.length > 0
          Geocoder.log(:debug, "Parsing response: #{raw_data[0..500]}...")
        end

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
