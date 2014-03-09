require 'geocoder/lookups/base'
require "geocoder/results/geocodio"

module Geocoder::Lookup
  class Geocodio < Base

    def name
      "Geocodio"
    end

    def query_url(query)
      path = query.reverse_geocode? ? "reverse" : "geocode"
      "#{protocol}://api.geocod.io/v1/#{path}?#{url_query_string(query)}"
    end

    def results(query)
      return [] unless doc = fetch_data(query)
      return doc["results"] if doc['error'].nil?
      
      if doc['error'] == 'Invalid API key'
        raise_error(Geocoder::InvalidApiKey) ||
          warn("Geocodio service error: invalid API key.")
      elsif doc['error'].match(/You have reached your daily maximum/)
        raise_error(Geocoder::OverQueryLimitError, doc['error']) ||
          warn("Geocodio service error: #{doc['error']}.")
      else
        raise_error(Geocoder::InvalidRequest, doc['error']) ||
          warn("Geocodio service error: #{doc['error']}.")
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
