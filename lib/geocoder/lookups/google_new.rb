require 'geocoder/lookups/google_base'
require 'geocoder/results/google_new'

module Geocoder::Lookup
  class GoogleNew < GoogleBase
    def required_api_key_parts
      ["key"]
    end

    private

    def base_url
      "#{protocol}://places.googleapis.com/v1/places"
    end

    def valid_response?(response)
      json = parse_json(response.body)
      error_status = json.dig('error', 'status') if json

      super(response) and error_status.nil?
    end

    def results(query)
      return [] unless doc = fetch_data(query)

      error = doc['error']
      return doc if error.nil?

      case error['status']
      when 'RESOURCE_EXHAUSTED'
        raise_error(Geocoder::OverQueryLimitError) ||
          Geocoder.log(:warn, "#{name} API error: resource exhausted.")
      when 'PERMISSION_DENIED'
        raise_error(Geocoder::RequestDenied, error['message']) ||
          Geocoder.log(:warn, "#{name} API error: permission denied (#{error['message']}).")
      when 'INVALID_ARGUMENT'
        raise_error(Geocoder::InvalidRequest, error['message']) ||
          Geocoder.log(:warn, "#{name} API error: invalid request (#{error['message']}).")
      end

      return []
    end

    def make_api_request(query)
      uri = URI.parse(query_url(query))

      http_client.start(uri.host, uri.port, use_ssl: use_ssl?) do |client|
        req = Net::HTTP::Get.new(uri.request_uri)
        req["X-Goog-Api-Key"] = configuration.api_key

        # Add field mask if present
        if field_mask = query.options[:fields] || configuration[:fields]
          req["X-Goog-FieldMask"] = field_mask
        end

        client.request(req)
      end
    end

    def query_url_google_params(query)
      params = {}
      params[:languageCode] = query.language || configuration.language if query.language || configuration.language
      params[:regionCode] = query.options[:region] if query.options[:region]
      params
    end

    def query_url_params(query)
      # Don't include API key in URL params, it will be sent in the header
      query_url_google_params(query).merge(super.except(:key))
    end
  end
end
