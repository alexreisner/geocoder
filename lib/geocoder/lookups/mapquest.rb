require 'geocoder/lookups/base'
require "geocoder/lookups/nominatim"
require "geocoder/results/mapquest"

module Geocoder::Lookup
  class Mapquest < Nominatim

    private # ---------------------------------------------------------------

    def query_url(query)
      params = query_url_params(query)
      method = query.reverse_geocode? ? "reverse" : "search"
      "http://open.mapquestapi.com/#{method}?" + hash_to_query(params)
    end
  end
end
