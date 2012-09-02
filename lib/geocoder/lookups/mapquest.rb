require 'geocoder/lookups/base'
require "geocoder/lookups/nominatim"
require "geocoder/results/mapquest"

module Geocoder::Lookup
  class Mapquest < Nominatim

    private # ---------------------------------------------------------------

    def query_url(query)
      method = query.reverse_geocode? ? "reverse" : "search"
      "http://open.mapquestapi.com/#{method}?" + url_query_string(query)
    end
  end
end
