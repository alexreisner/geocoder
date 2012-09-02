require 'geocoder/lookups/base'
require "geocoder/results/nominatim"

module Geocoder::Lookup
  class Nominatim < Base

    def map_link_url(coordinates)
      "http://www.openstreetmap.org/?lat=#{coordinates[0]}&lon=#{coordinates[1]}&zoom=15&layers=M"
    end

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
      "http://nominatim.openstreetmap.org/#{method}?" + hash_to_query(params)
    end
  end
end
