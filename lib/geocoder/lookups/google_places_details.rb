require "geocoder/lookups/base"
require "geocoder/results/google_places_details"
require 'logger'

module Geocoder::Lookup
  class GooglePlacesDetails < Base
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
      place_id = query.text
      "#{protocol}://places.googleapis.com/v1/places/#{place_id}?"
    end

    def make_api_request(query)
      uri = URI.parse(query_url(query))

      Geocoder.log(:debug, "Request URL: #{uri}")

      # Create a new HTTP request
      http_client.start(uri.host, uri.port, use_ssl: true) do |client|
        req = Net::HTTP::Get.new(uri.request_uri)
        req["X-Goog-Api-Key"] = configuration.api_key
        req["X-Goog-FieldMask"] = "displayName,formattedAddress,location"

        Geocoder.log(:debug, "Headers: #{req.to_hash.inspect}")

        response = client.request(req)
        Geocoder.log(:debug, "Response code: #{response.code}")

        response_body = response.body[0..300]
        Geocoder.log(:debug, "Response: #{response_body}...")

        response
      end
    end

    def valid_response?(response)
      json = parse_json(response.body)
      return false unless json
      return true unless json["error"]
      false
    end

    def results(query)
      doc = fetch_data(query)
      return [] unless doc

      # Check for errors
      if doc["error"]
        error_message = doc["error"]["message"]
        error_status = doc["error"]["status"]

        Geocoder.log(:warn, "Error: #{error_status} - #{error_message}")
        return []
      end

      # Return the place data
      [doc]
    end

    def query_url_params(query)
      # No URL parameters needed - they all go in headers
      {}
    end

    def default_field_mask
      # Must properly format fields according to Google Place API requirements
      [
        "id",
        "displayName",
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
        "internationalPhoneNumber",
        "addressComponents"
      ].join(',')
    end

    def fields(query)
      if query.options.has_key?(:fields)
        return format_fields(query.options[:fields])
      end

      if configuration.has_key?(:fields)
        return format_fields(configuration[:fields])
      end

      nil
    end

    def format_fields(*fields)
      flattened = fields.flatten.compact
      return if flattened.empty?

      flattened.join(',')
    end
  end
end
