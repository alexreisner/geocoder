require 'geocoder/lookups/base'
require "geocoder/results/nominatim"

module Geocoder::Lookup
  class Nominatim < Base
  
    def map_link_url(coordinates)
      "http://nominatim.openstreetmap.org/reverse?format=html&lat=#{coordinates[0]}&lon=#{coordinates[1]}&zoom=18&addressdetails=1"
    end

    def results(query, reverse = false)
      return [] unless doc = fetch_data(query, reverse)
      if doc.any?
        return doc[0]['place_id'] != "" ? doc : []
      else
        warn "Nominatim Geocoding Adress not founr or API error."
        return []
      end
    end

    def query_url(query, reverse = false)
      params = {
        :q => query,
        :format => "json",
		:polygon => "1",
        :addressdetails => "1",
#        :locale => "#{Geocoder::Configuration.language}_US",
      }
      "http://nominatim.openstreetmap.org/search?" + hash_to_query(params)
    end  
  end
end