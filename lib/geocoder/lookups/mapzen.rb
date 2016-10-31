require 'geocoder/lookups/pelias'
require 'geocoder/results/mapzen'

# https://mapzen.com/documentation/search/search/ for more information
module Geocoder::Lookup
  class Mapzen < Pelias
    def name
      'Mapzen'
    end

    def endpoint
      configuration[:endpoint] || 'search.mapzen.com'
    end
  end
end
