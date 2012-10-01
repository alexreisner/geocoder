require 'geocoder/lookups/base'
require "geocoder/results/yahoo"

module Geocoder::Lookup
  class Yahoo < Base

    def map_link_url(coordinates)
      "http://maps.yahoo.com/#lat=#{coordinates[0]}&lon=#{coordinates[1]}"
    end

    private # ---------------------------------------------------------------

    def results(query)
      return [] unless doc = fetch_data(query)
      doc = doc['ResultSet']
      # seems to have Error == 7 when no results, though this is not documented
      if [0, 7].include?(doc['Error'].to_i)
        if doc['Found'].to_i > 0
          r = doc['Result']
          return r.is_a?(Array) ? r : [r]
        else
          return []
        end
      else
        warn "Yahoo Geocoding API error: #{doc['Error']} (#{doc['ErrorMessage']})."
        return []
      end
    end

    def query_url_params(query)
      super.merge(
        :location => query.sanitized_text,
        :flags => "JXTSR",
        :gflags => "AC#{'R' if query.reverse_geocode?}",
        :locale => "#{Geocoder::Configuration.language}_US",
        :appid => Geocoder::Configuration.api_key
      )
    end

    def query_url(query)
      "http://where.yahooapis.com/geocode?" + url_query_string(query)
    end
  end
end
