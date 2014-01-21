require 'geocoder/lookups/base'
require "geocoder/results/geocodio"

module Geocoder::Lookup
  class Geocodio < Base

    def name
      "Geocodio"
    end

    def query_url(query)
      "#{protocol}://api.geocod.io/v1/geocode?#{url_query_string(query)}"
    end

    def results(query)
      return [] unless doc = fetch_data(query)
      if doc['error'].nil?
        return doc["results"]
      else
        warn "Geocodio service error: #{doc['error']}."
      end
      []
    end

    private # ---------------------------------------------------------------

    def query_url_params(query)
      {
        :api_key => configuration.api_key,
        :q => query.sanitized_text
      }.merge(super)
    end
  end
end
