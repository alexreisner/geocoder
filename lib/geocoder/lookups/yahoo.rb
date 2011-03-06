require 'geocoder/lookups/base'
require "geocoder/results/yahoo"

module Geocoder::Lookup
  class Yahoo < Base

    private # ---------------------------------------------------------------

    def result(query, reverse = false)
      doc = fetch_data(query, reverse)
      if doc = doc['ResultSet'] and doc['Error'] == 0
        if Geocoder::Configuration.safe_mode and doc['Results'].count > 1
          warn "Ambiguous address returned #{doc['Results'].count} matches"
        else
          doc['Results'].first
        end
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
      "http://where.yahooapis.com/geocode?" + hash_to_query(params)
    end
  end
end

