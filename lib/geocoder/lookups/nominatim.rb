require 'geocoder/lookups/base'
require "geocoder/results/nominatim"

module Geocoder::Lookup
  class Nominatim < Base
  
    def map_link_url(coordinates)
      "http://nominatim.openstreetmap.org/reverse?format=html&lat=#{coordinates[0]}&lon=#{coordinates[1]}&zoom=18&addressdetails=1"
    end

    def results(query, reverse = false)
      return [] unless doc = fetch_data(query, reverse)
	  if doc.kind_of?(Array)
		  if doc.any?
			return doc[0]['place_id'] != "" ? doc : []
		  else
			warn "Address not found or Nominatim Geocoding API error."
			return []
		  end	  
	  else
		return doc['place_id'] != "" ? doc = [] << doc : []
	  end
    end

    def query_url(query, reverse = false)
      params = {
        :format => "json",
		:polygon => "1",
        :addressdetails => "1",
#        :locale => "#{Geocoder::Configuration.language}_US",
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
      "http://nominatim.openstreetmap.org/#{method}?" + hash_to_query(params)
    end  

  end
end