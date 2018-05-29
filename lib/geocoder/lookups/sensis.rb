require 'geocoder/lookups/base'
require 'geocoder/results/sensis'

module Geocoder

  module Lookup

    class Sensis < Base

      def name
        "Sensis"
      end

      def required_api_key_parts
        ["auth token", "auth password"]
      end

      def query_url(query)
        "#{protocol}://#{configured_host}/v2/service/geocode/#{configuration.type}"
      end

      def query_url_params(query)
        query.options[:params] || {}
      end

      def supported_protocols
        [:https]
      end

      private

      def configured_host
        configuration[:host] || "api-ems-stage.ext.sensis.com.au"
      end

      def cache_key(query)
        query.to_s
      end

      def results(query)
        return [] unless doc = fetch_data(query)

        if doc['code'] == 401
          raise_error ::Geocoder::RequestDenied, "Bad Request: #{doc['message']}"
        elsif doc['code'] == 400
          raise_error ::Geocoder::InvalidRequest,"Bad Request: #{doc['message']}"
        elsif doc['code']
          raise_error ::Geocoder::Error, "Unable to access Sensis API: #{doc['code']}. Body:\n#{doc['message']}"
        end
        doc["results"]
      end

      def url_query_string(query)
        if configuration.type == 'unstructured'
          return {"query" => query.text}.to_json
        else
          return {"address" => query.text}.to_json
        end
      end
    end

  end
end
