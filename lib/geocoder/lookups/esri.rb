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

    def generate_token(expires=1440)
      # creates a new token that will expire in 1 day by default
      getToken = Net::HTTP.post_form URI('https://www.arcgis.com/sharing/rest/oauth2/token'),
        f: 'json',
        client_id: configuration.api_key[0],
        client_secret: configuration.api_key[1],
        grant_type: 'client_credentials',
        expiration: expires # (minutes) max: 20160, default: 1 day

      if JSON.parse(getToken.body)['error']
        raise_error(Geocoder::InvalidApiKey) || Geocoder.log(:warn, "Couldn't generate ESRI token: invalid API key.")
      else
        token_value = JSON.parse(getToken.body)['access_token']
        expires_at = Time.now + expires.minutes
        Geocoder::EsriToken.new(token_value, expires_at)
      end
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
      params[:forStorage] = configuration.for_storage if configuration.for_storage
      params.merge(super)
    end

    def token
      if configuration.token && configuration.token.valid? # if we have a token, use it
        configuration.token.to_s
      elsif configuration.api_key # generate a new token if we have credentials
        token_instance = generate_token
        Geocoder.configure(:esri => {:token => token_instance})
        token_instance.to_s
      end
    end

  end
end
