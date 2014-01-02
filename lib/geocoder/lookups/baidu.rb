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
      if query.ip_address?
        "http://api.map.baidu.com/location/ip?" + url_query_string(query)
      else
        "http://api.map.baidu.com/geocoder/v2/?" + url_query_string(query)
      end
    end

    private # ---------------------------------------------------------------

    def results(query, reverse = false)
      return [] unless doc = fetch_data(query)
      case doc['status']; when 0
        if query.ip_address?
          return [doc]
        else
          return [doc['result']] unless doc['result'].blank?
        end
      when 1, 3, 4
        raise_error(Geocoder::Error, messages) ||
          warn("Baidu Geocoding API error: server error.")
      when 2
        raise_error(Geocoder::InvalidRequest, messages) ||
          warn("Baidu Geocoding API error: invalid request.")
      when 5
        raise_error(Geocoder::InvalidApiKey, messages) ||
          warn("Baidu Geocoding API error: invalid api key.")
      when 101, 102, 200..299
        raise_error(Geocoder::RequestDenied) ||
          warn("Baidu Geocoding API error: request denied.")
      when 300..399
        raise_error(Geocoder::OverQueryLimitError) ||
          warn("Baidu Geocoding API error: over query limit.")
      end
      return []
    end

    def query_url_params(query)
      {
        (query_key(query)) => query.sanitized_text,
        :ak => configuration.api_key,
        :output => "json"
      }.merge(super)
    end

    def query_key(query)
      if query.ip_address?
        :ip
      elsif query.reverse_geocode
        :location
      else
        :address
      end
    end

  end
end

