require 'geocoder/lookups/base'
require "geocoder/results/amap"

module Geocoder::Lookup
  class Amap < Base

    def name
      "AMap"
    end

    def required_api_key_parts
      ["key"]
    end

    def query_url(query)
      path = query.reverse_geocode? ? 'regeo' : 'geo'
      "http://restapi.amap.com/v3/geocode/#{path}?" + url_query_string(query)
    end

    private # ---------------------------------------------------------------

    def results(query, reverse = false)
      return [] unless doc = fetch_data(query)
      case doc['status']
      when "1"
        if query.reverse_geocode?
          return [doc['regeocodes']] unless doc['regeocodes'].blank?
        else
          return [doc['geocodes']] unless doc['geocodes'].blank?
        end
      else
        raise_error(Geocoder::Error, "server error.") ||
          warn("#{self.name} Geocoding API error: server error[#{doc['info']}]")
      end
      return []
    end

    def query_url_params(query)
      params = {
        :key => configuration.api_key,
        :output => "json"
      }
      if query.reverse_geocode?
        params[:location] = revert_coordinates(query.text)
        params[:extensions] = "all"
        params[:coordsys] = "gps"
      else
        params[:address] = query.sanitized_text
      end
      params.merge(super)
    end

    def revert_coordinates(text)
      [text[1],text[0]].join(",")
    end

  end
end
