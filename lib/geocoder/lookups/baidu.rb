require 'geocoder/lookups/base'
require "geocoder/results/baidu"

module Geocoder::Lookup
  class Baidu < Base

    def name
      "Baidu"
    end

    def required_api_key_parts
      ["key"]
    end

    def query_url(query)
      "http://api.map.baidu.com/geocoder/v2/?" + url_query_string(query)
    end

    private # ---------------------------------------------------------------

    def results(query, reverse = false)
      return [] unless doc = fetch_data(query)
      case doc['status']
      when 0
        return [doc['result']] unless doc['result'].blank?
      when 1, 3, 4
        raise_error(Geocoder::Error, "server error.") ||
          warn("Baidu Geocoding API error: server error.")
      when 2
        raise_error(Geocoder::InvalidRequest, "invalid request.") ||
          warn("Baidu Geocoding API error: invalid request.")
      when 5
        raise_error(Geocoder::InvalidApiKey, "invalid api key") ||
          warn("Baidu Geocoding API error: invalid api key.")
      when 101, 102, 200..299
        raise_error(Geocoder::RequestDenied, "request denied") ||
          warn("Baidu Geocoding API error: request denied.")
      when 300..399
        raise_error(Geocoder::OverQueryLimitError, "over query limit.") ||
          warn("Baidu Geocoding API error: over query limit.")
      end
      return []
    end

    def query_url_params(query)
      {
        (query.reverse_geocode? ? :location : :address) => query.sanitized_text,
        :ak => configuration.api_key,
        :output => "json"
      }.merge(super)
    end

  end
end

