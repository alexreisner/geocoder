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

    def query_url_params(query)
      params = super.merge(
        :format => "json",
        :polygon => "1",
        :addressdetails => "1",
        :"accept-language" => Geocoder::Configuration.language
      )
      if query.reverse_geocode?
        lat,lon = query.coordinates
        params[:lat] = lat
        params[:lon] = lon
      else
        params[:q] = query.sanitized_text
      end
      params
    end

    def query_url(query)
      method = query.reverse_geocode? ? "reverse" : "search"
      "http://nominatim.openstreetmap.org/#{method}?" + url_query_string(query)
    end
  end
end
