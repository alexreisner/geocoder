require 'geocoder/lookups/base'
require "geocoder/results/yahoo"

module Geocoder::Lookup
  class Yahoo < Base

    private # ---------------------------------------------------------------

    ##
    # Returns a parsed Yahoo geocoder search result (hash).
    # Returns nil if non-200 HTTP response, timeout, or other error.
    #
    def results(query, reverse = false)
      doc = fetch_data(query, reverse)
      if doc = doc['ResultSet'] and doc['Error'] == 0
        doc['Results']
      else
        warn "Yahoo Geocoding API error: #{doc['Error']} (#{doc['ErrorMessage']})."
      end
    end

    def query_url(query, reverse = false)
      params = {
        :location =>  query,
        :flags => "JXTSR",
        :gflags => "AC#{'R' if reverse}",
        :appid => Geocoder::Configuration.yahoo_appid
      }
      "http://where.yahooapis.com/geocode?" + params.to_query
    end
  end
end

