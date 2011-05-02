require 'geocoder/lookups/base'
require "geocoder/results/yandex"

module Geocoder::Lookup
  class Yandex < Base

    def map_link_url(coordinates)
      "http://maps.yandex.ru/?ll=#{coordinates.reverse.join(',')}"
    end

    private # ---------------------------------------------------------------

    def results(query, reverse = false)
      return [] unless doc = fetch_data(query, reverse)
      if err = doc['error']
        warn "Yandex Geocoding API error: #{err['status']} (#{err['message']})."
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

    def query_url(query, reverse = false)
      query = query.split(",").reverse.join(",") if reverse
      params = {
        :geocode => query,
        :format => "json",
        :plng => "#{Geocoder::Configuration.language}", # supports ru, uk, be
        :key => Geocoder::Configuration.api_key
      }
      "http://geocode-maps.yandex.ru/1.x/?" + hash_to_query(params)
    end
  end
end
