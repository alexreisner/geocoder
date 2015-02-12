require 'geocoder/lookups/base'
require "geocoder/results/yandex"

module Geocoder::Lookup
  class Yandex < Base

    def name
      "Yandex"
    end

    def map_link_url(coordinates)
      "http://maps.yandex.ru/?ll=#{coordinates.reverse.join(',')}"
    end

    def query_url(query)
      "#{protocol}://geocode-maps.yandex.ru/1.x/?" + url_query_string(query)
    end

    private # ---------------------------------------------------------------

    def results(query)
      return [] unless doc = fetch_data(query)
      if err = doc['error']
        if err["status"] == 401 and err["message"] == "invalid key"
          raise_error(Geocoder::InvalidApiKey) || warn("Invalid API key.")
        else
          warn "Yandex Geocoding API error: #{err['status']} (#{err['message']})."
        end
        return []
      end
      if doc = doc['response']['GeoObjectCollection']
        meta = doc['metaDataProperty']['GeocoderResponseMetaData']
        return meta['found'].to_i > 0 ? doc['featureMember'] : []
      else
        warn "Yandex Geocoding API error: unexpected response format."
        return []
      end
    end

    def query_url_params(query)
      if query.reverse_geocode?
        q = query.coordinates.reverse.join(",")
      else
        q = query.sanitized_text
      end
      {
        :geocode => q,
        :format => "json",
        :plng => "#{query.language || configuration.language}", # supports ru, uk, be
        :key => configuration.api_key
      }.merge(super)
    end
  end
end
