require "geocoder/lookups/google"
require "geocoder/results/google_places_search"
require "json"

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
        use_new_places_api = @query.options.fetch(:use_new_places_api, configuration.use_new_places_api)
        use_new_places_api ? 'places' : 'candidates'
      end

      def base_query_url(query)
        use_new_places_api = query.options.fetch(:use_new_places_api, configuration.use_new_places_api)
        if use_new_places_api
          "#{protocol}://places.googleapis.com/v1/places:searchText?"
        else
          "#{protocol}://maps.googleapis.com/maps/api/place/findplacefromtext/json?"
        end
      end

      def query_url(query)
        use_new_places_api = query.options.fetch(:use_new_places_api, configuration.use_new_places_api)
        @query = query

        if use_new_places_api
          base_query_url(query) + url_query_string(query)
        else
          super(query)
        end
      end

      def make_api_request(query)
        use_new_places_api = query.options.fetch(:use_new_places_api, configuration.use_new_places_api)
        @query = query

        if use_new_places_api
          uri = URI.parse(query_url(query))
          http_client.start(uri.host, uri.port, use_ssl: use_ssl?) do |client|
            req = Net::HTTP::Post.new(uri.request_uri)
            req.body = request_body_json(query)
            req["Content-Type"] = "application/json"
            req["X-Goog-Api-Key"] = configuration.api_key
            client.request(req)
          end
        else
          super(query)
        end
      end

      def request_body_json(query)
        use_new_places_api = query.options.fetch(:use_new_places_api, configuration.use_new_places_api)
        if use_new_places_api
          body = {
            textQuery: query.text
          }

          body[:locationBias] = locationbias(query) if locationbias(query)
          body[:languageCode] = query.language || configuration.language if query.language || configuration.language

          if fields(query)
            body[:fields] = fields(query)
          end

          JSON.generate(body)
        else
          nil
        end
      end

      def query_url_google_params(query)
        @query = query
        use_new_places_api = query.options.fetch(:use_new_places_api, configuration.use_new_places_api)

        if use_new_places_api
          {}
        else
          {
            input: query.text,
            inputtype: 'textquery',
            fields: fields(query),
            locationbias: locationbias(query),
            language: query.language || configuration.language
          }
        end
      end

      def fields(query)
        if query.options.has_key?(:fields)
          return format_fields(query.options[:fields])
        end

        if configuration.has_key?(:fields)
          return format_fields(configuration[:fields])
        end

        default_fields
      end

      def default_fields
        use_new_places_api = @query.options.fetch(:use_new_places_api, configuration.use_new_places_api)

        if use_new_places_api
          basic = %w[businessStatus formattedAddress location viewport iconMaskBaseUri iconBackgroundColor displayName photos id plusCode types]
          contact = %w[regularOpeningHours]
          atmosphere = %W[priceLevel rating userRatingsTotal]
        else
          basic = %w[business_status formatted_address geometry icon name photos place_id plus_code types]
          contact = %w[opening_hours]
          atmosphere = %W[price_level rating user_ratings_total]
        end

        format_fields(basic, contact, atmosphere)
      end

      def format_fields(*fields)
        flattened = fields.flatten.compact
        return if flattened.empty?

        flattened.join(',')
      end

      def locationbias(query)
        if query.options.has_key?(:locationbias)
          query.options[:locationbias]
        else
          configuration[:locationbias]
        end
      end
    end
  end
end
