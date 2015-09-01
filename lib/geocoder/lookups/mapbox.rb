require 'geocoder/lookups/base'
require "geocoder/results/mapbox"

module Geocoder::Lookup
  class Mapbox < Base

    def name
      "Mapbox"
    end

    def query_url(query)
      "#{protocol}://api.mapbox.com/geocoding/v5/#{dataset}/#{url_query_string(query)}.json?access_token=#{configuration.api_key}"
    end

    private # ---------------------------------------------------------------

    def results(query)
      return [] unless data = fetch_data(query)
      if data['features']
        sort_relevant_feature(data['features'])
      elsif data['message'] =~ /Invalid\sToken/
        raise_error(Geocoder::InvalidApiKey, data['message'])
      else
        []
      end
    end

    def url_query_string(query)
      require 'cgi' unless defined?(CGI) && defined?(CGI.escape)
      CGI.escape query.text.to_s
    end

    def dataset
      "mapbox.places"
    end

    def supported_protocols
      [:https]
    end

    def sort_relevant_feature(features)
      features.sort_by do |feature|
        feature["relevance"]
      end.reverse
    end
  end
end
