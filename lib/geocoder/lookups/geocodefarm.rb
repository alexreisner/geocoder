require 'geocoder/lookups/base'
require "geocoder/results/geocodefarm"

module Geocoder::Lookup
  class Geocodefarm < Base

    def name
      "Geocodefarm"
    end

    def required_api_key_parts
      ["key"]
    end

    def query_url(query)
      direction = direction(query)
      search_parameter = search_parameter(query)
      base_url + direction(query) + "/json/" + configuration.api_key + "/" + search_parameter
    end

    private # ---------------------------------------------------------------

    def base_url
      "http://www.geocodefarm.com/api/"
    end

    def results(query)
      return [] unless doc = fetch_data(query)

      doc = doc['geocoding_results']

      if doc['STATUS']['status'] == 'SUCCESS'
        return [doc]
      elsif doc['STATUS']['status'] == 'FAILED, NO_RESULTS'
        return []
      elsif doc['STATUS']['access'] == "API_KEY_INVALID"
         raise_error(Geocoder::InvalidApiKey) || warn("Invalid Geocodefarm API key.")
      else
        warn "Geocodefarm API Error - Access: #{doc['STATUS']['access']} | Status: #{doc['STATUS']['status']}"
      end
      return []
    end

    def direction(query)
      if query.reverse_geocode?
        direction = "reverse"
      else
        direction = "forward"
      end
    end

    def search_parameter(query)
      if query.reverse_geocode?
        query.coordinates.join('/')
      else
        URI.escape(query.sanitized_text)
      end
    end

    def search_coordinates(query)

    end

  end
end
