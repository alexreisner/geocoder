require 'geocoder/lookups/base'
require "geocoder/results/esri"

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
      params[:token] = token if configuration.api_key
      params[:forStorage] = configuration.for_storage if configuration.for_storage
      params.merge(super)
    end

    def token
      unless token_is_valid
        getToken = Net::HTTP.post_form URI('https://www.arcgis.com/sharing/rest/oauth2/token'),
          f: 'json',
          client_id: configuration.api_key[0],
          client_secret: configuration.api_key[1],
          grant_type: 'client_credentials',
          expiration: 1440 # valid for one day,

          @token = JSON.parse(getToken.body)['access_token']
          @token_expires = Time.now + 1.day
      end
      return @token
    end

    def token_is_valid
      @token && @token_expires > Time.now
    end

  end
end
