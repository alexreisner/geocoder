require 'geocoder/lookups/google_new'
require 'geocoder/results/google_places_details_new'

module Geocoder::Lookup
  class GooglePlacesDetailsNew < GoogleNew
    def name
      "Google Places Details (New)"
    end

    private

    def base_query_url(query)
      # The place_id is encoded to handle any special characters
      encoded_place_id = URI.encode_www_form_component(query.text)
      "#{base_url}/#{encoded_place_id}?"
    end

    def results(query)
      result = super(query)
      return [result] unless result.is_a? Array

      result
    end

    def default_field_mask
      "id,displayName.text,formattedAddress,location,types,websiteUri,rating,userRatingCount,priceLevel,businessStatus,regularOpeningHours,photos,internationalPhoneNumber,addressComponents"
    end

    def make_api_request(query)
      uri = URI.parse(query_url(query))

      http_client.start(uri.host, uri.port, use_ssl: use_ssl?) do |client|
        req = Net::HTTP::Get.new(uri.request_uri)
        req["X-Goog-Api-Key"] = configuration.api_key

        # Add the required FieldMask header
        field_mask = query.options[:fields] || configuration[:fields] || default_field_mask
        req["X-Goog-FieldMask"] = field_mask

        client.request(req)
      end
    end

    def query_url_google_params(query)
      params = {}
      params[:languageCode] = query.language || configuration.language if query.language || configuration.language
      params[:regionCode] = query.options[:region] if query.options[:region]
      params
    end
  end
end
