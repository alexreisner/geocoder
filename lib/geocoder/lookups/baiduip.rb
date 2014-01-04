require 'geocoder/lookups/base'
require 'geocoder/results/baiduip'

module Geocoder::Lookup
  class Baiduip < Base

    def name
      "BaiduIP"
    end

    def required_api_key_parts
      ["key"]
    end

    def query_url(query)
      "http://api.map.baidu.com/location/ip?" + url_query_string(query)
    end

    private # ---------------------------------------------------------------

    def results(query, reverse = false)
      return [] unless doc = fetch_data(query)
      case doc['status']
      when 0
        return [doc['content']] unless doc['content'].blank?
      when 1, 3, 4
        raise_error(Geocoder::Error, messages) ||
          warn("Baidu IP Geocoding API error: server error.")
      when 2
        raise_error(Geocoder::InvalidRequest, messages) ||
          warn("Baidu IP Geocoding API error: invalid request.")
      when 5
        raise_error(Geocoder::InvalidApiKey, messages) ||
          warn("Baidu IP Geocoding API error: invalid api key.")
      when 101, 102, 200..299
        raise_error(Geocoder::RequestDenied) ||
          warn("Baidu IP Geocoding API error: request denied.")
      when 300..399
        raise_error(Geocoder::OverQueryLimitError) ||
          warn("Baidu IP Geocoding API error: over query limit.")
      end
      return []
    end

    def query_url_params(query)
      {
        :ip => query.sanitized_text,
        :ak => configuration.api_key,
        :coor => "bd09ll"
      }.merge(super)
    end

  end
end
