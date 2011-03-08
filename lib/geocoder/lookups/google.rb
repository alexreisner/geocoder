require 'geocoder/lookups/base'
require "geocoder/results/google"

module Geocoder::Lookup
  class Google < Base

    private # ---------------------------------------------------------------

    def result(query, reverse = false)
      doc = fetch_data(query, reverse)
      case doc['status']; when "OK" # OK status implies >0 results
        doc['results'].first
      when "OVER_QUERY_LIMIT"
        warn "Google Geocoding API error: over query limit."
      when "REQUEST_DENIED"
        warn "Google Geocoding API error: request denied."
      when "INVALID_REQUEST"
        warn "Google Geocoding API error: invalid request."
      end
    end

    def query_url(query, reverse = false)
      params = {
        (reverse ? :latlng : :address) => query,
        :sensor => "false"
      }
      "http://maps.google.com/maps/api/geocode/json?" + hash_to_query(params)
    end
  end
end

