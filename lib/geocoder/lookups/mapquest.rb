require 'geocoder/lookups/base'
require "geocoder/results/mapquest"

module Geocoder::Lookup
  class Mapquest < Base

    private # ---------------------------------------------------------------

    def results(query)
      return [] unless doc = fetch_data(query)
      doc.is_a?(Array) ? doc : [doc]
    end

    def query_url(query)
      params = {
        :format => "json",
        :polygon => "1",
        :addressdetails => "1",
        :"accept-language" => Geocoder::Configuration.language
      }
      if (query.reverse_geocode?)
        method = 'reverse'
        lat,lon = query.coordinates
        params[:lat] = lat
        params[:lon] = lon
      else
        method = 'search'
        params[:q] = query.sanitized_text
      end
      "http://open.mapquestapi.com/#{method}?" + hash_to_query(params)
    end
  end
end
