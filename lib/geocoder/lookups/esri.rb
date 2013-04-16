require 'geocoder/lookups/base'
require "geocoder/results/esri"
require 'rack/utils'

module Geocoder::Lookup
  class Esri < Base
    
    def name
      "Esri"
    end

    def query_url(query)
      search_keyword = query.reverse_geocode? ? "reverseGeocode" : "find"

      "#{protocol}://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/#{search_keyword}?" +
        url_query_string(query)
    end

    private # ---------------------------------------------------------------

    def results(query)
      return [] unless doc = fetch_data(query)

      if (!query.reverse_geocode?)
        return [] if doc['locations'].empty?
      end

      if (doc['error'].nil?)
        return [ doc ]
      else
        return []
      end
    end

    def query_url_params(query)
      if query.reverse_geocode?
        {
          :location => query.text.reverse.join(','),
          :outFields => :*,
          :p => :pjson
          }.merge(super)
      else
        {
          :f => :pjson,
          :outFields => :*,
          :text => query.sanitized_text
        }.merge(super)
      end
    end  

  end
end