require 'geocoder/lookups/base'
require "geocoder/results/google"

module Geocoder::Lookup
  class Google < Base

    private # ---------------------------------------------------------------

    ##
    # Returns a parsed Google geocoder search result (hash).
    # Returns nil if non-200 HTTP response, timeout, or other error.
    #
    def results(query, reverse = false)
      doc = fetch_data(query, reverse)
      case doc['status']; when "OK"
        doc['results']
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
      "http://maps.google.com/maps/api/geocode/json?" + params.to_query
    end
  end
end

