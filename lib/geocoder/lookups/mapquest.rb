require 'geocoder/lookups/base'
require "geocoder/results/mapquest"

module Geocoder::Lookup
  class Mapquest < Base

    def map_link_url(coordinates)
      "http://www.openstreetmap.org/?lat=#{coordinates[0]}&lon=#{coordinates[1]}&zoom=15&layers=M"
    end

    private # ---------------------------------------------------------------

    def results(query, reverse = false)
      return [] unless doc = fetch_data(query, reverse)
      doc.is_a?(Array) ? doc : [doc]
    end

    def query_url(query, reverse = false)
      params = {
        :format => "json",
        :json_callback=>"?",
        :polygon => "1",
        :addressdetails => "1",
        :"accept-language" => Geocoder::Configuration.language
      }
      if (reverse)
        method = 'reverse'
        parts = query.split(/\s*,\s*/);
        params[:lat] = parts[0]
        params[:lon] = parts[1]
      else
        method = 'search'
        params[:q] = query
      end
      "http://open.mapquestapi.com/#{method}?" + hash_to_query(params)
    end
  end
end
