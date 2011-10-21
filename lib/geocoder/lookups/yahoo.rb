require 'geocoder/lookups/base'
require "geocoder/results/yahoo"

module Geocoder::Lookup
  class Yahoo < Base

    def map_link_url(coordinates)
      "http://maps.yahoo.com/#lat=#{coordinates[0]}&lon=#{coordinates[1]}"
    end

    private # ---------------------------------------------------------------

    def results(query, reverse_or_options = false)
      return [] unless doc = fetch_data(query, reverse_or_options)
      if doc = doc['ResultSet'] and doc['Error'] == 0
        return doc['Found'] > 0 ? doc['Results'] : []
      else
        warn "Yahoo Geocoding API error: #{doc['Error']} (#{doc['ErrorMessage']})."
        return []
      end
    end

    def query_url(query, reverse_or_options = false)
      reverse, options = extract_reverse_and_options(reverse_or_options)

      params = {
        :location => query,
        :flags => "JXTSR",
        :gflags => "AC#{'R' if reverse}",
        :locale => "#{Geocoder::Configuration.language}_US",
        :appid => Geocoder::Configuration.api_key
      }
      "http://where.yahooapis.com/geocode?" + hash_to_query(params)
    end
  end
end
