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
      error_status = json.dig('errpr', 'status') if json

      super(response) and error_status.nil?
    end

    def results(query)
      return [] unless doc = fetch_data(query)

      error = doc['error']
      return doc if error.nil?

      case error['status']
      when 'PERMISSION_DENIED'
        raise_error(Geocoder::RequestDenied, error['message']) ||
          Geocoder.log(:warn, "#{name} API error: request denied (#{error['message']}).")
      when 'INVALID_ARGUMENT'
        raise_error(Geocoder::InvalidRequest, error['message']) ||
          Geocoder.log(:warn, "#{name} API error: invalid request (#{error['message']}).")
      end

      return []
    end

    def query_url_google_params(query)
      {}
    end

    def query_url_params(query)
      query_url_google_params(query).merge(
        :key => configuration.api_key
      ).merge(super)
    end
  end
end

