require 'geocoder/lookups/base'
require "geocoder/results/nominatim"

module Geocoder::Lookup
  class Nominatim < Base

    def map_link_url(coordinates)
      "http://www.openstreetmap.org/?lat=#{coordinates[0]}&lon=#{coordinates[1]}&zoom=15&layers=M"
    end

    private # ---------------------------------------------------------------

    def results(query, options = {})
      return [] unless doc = fetch_data(query, options)
      doc.is_a?(Array) ? doc : [doc]
    end

    def query_url(query, options = {})
      params = {
        :format => "json",
        :polygon => "1",
        :addressdetails => "1",
        :"accept-language" => Geocoder::Configuration.language
      }
      if (options[:reverse])
        method = 'reverse'
        parts = query.split(/\s*,\s*/);
        params[:lat] = parts[0]
        params[:lon] = parts[1]
      else
        method = 'search'
        params[:q] = query
      end
      "http://nominatim.openstreetmap.org/#{method}?" + hash_to_query(params)
    end
  end
end
