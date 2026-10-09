require 'geocoder/lookups/base'
require "geocoder/results/mapbox"

module Geocoder::Lookup
  class Mapbox < Base

    def name
      "Mapbox"
    end

    private # ---------------------------------------------------------------

    def base_query_url(query)
      endpoint = query.reverse_geocode? ? "reverse" : "forward"
      "#{protocol}://api.mapbox.com/search/geocode/v6/#{endpoint}?"
    end

    def results(query)
      return [] unless data = fetch_data(query)
      if data['features']
        data['features']
      elsif data['message'] =~ /Invalid\sToken/
        raise_error(Geocoder::InvalidApiKey, data['message'])
        []
      else
        []
      end
    end

    def query_url_params(query)
      params = {access_token: configuration.api_key}
      if query.reverse_geocode?
        lat, lon = query.coordinates
        params[:longitude] = lon
        params[:latitude] = lat
      else
        # truncate at first semicolon so Mapbox doesn't go into batch mode
        # (see Github issue #1299)
        params[:q] = query.text.to_s.split(';').first.to_s
      end
      params.merge(permanent_params).merge(super(query))
    end

    # The v5 permanent dataset was replaced by a request param in v6.
    def permanent_params
      return {} unless configuration[:dataset].to_s.include?("permanent")
      Geocoder.log(:warn, "DEPRECATION WARNING: the Mapbox :dataset option is not supported by the Geocoding v6 API and will be removed in a future version of Geocoder. Please remove it and pass params: {permanent: true} instead.")
      {permanent: true}
    end

    def supported_protocols
      [:https]
    end
  end
end
