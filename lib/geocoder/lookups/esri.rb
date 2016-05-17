require 'geocoder/lookups/base'
require "geocoder/results/esri"
require 'geocoder/esri_token'

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
        return [] if !doc['locations'] || doc['locations'].empty?
      end

      if (doc['error'].nil?)
        return [ doc ]
      else
        return []
      end
    end

    def query_url_params(query)
      params = {
        :f => "pjson",
        :outFields => "*"
      }
      if query.reverse_geocode?
        params[:location] = query.coordinates.reverse.join(',')
      else
        params[:text] = query.sanitized_text
      end
      params[:token] = token
      params[:forStorage] = configuration[:for_storage] if configuration[:for_storage]
      params.merge(super)
    end

    def token
      if configuration[:token] && configuration[:token].active? # if we have a token, use it
        configuration[:token].to_s
      elsif configuration.api_key # generate a new token if we have credentials
        token_instance = Geocoder::EsriToken.generate_token(*configuration.api_key)
        Geocoder.configure(:esri => {:token => token_instance})
        token_instance.to_s
      end
    end

  end
end
