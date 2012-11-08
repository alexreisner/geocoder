require 'geocoder/lookups/base'
require "geocoder/results/yahoo"
require 'oauth_util'

module Geocoder::Lookup
  class Yahoo < Base

    def map_link_url(coordinates)
      "http://maps.yahoo.com/#lat=#{coordinates[0]}&lon=#{coordinates[1]}"
    end

    private # ---------------------------------------------------------------

    def results(query)
      return [] unless doc = fetch_data(query)
      doc = doc['bossresponse']
      if doc['responsecode'].to_i == 200
        if doc['placefinder']['count'].to_i > 0
          return doc['placefinder']['results']
        else
          return []
        end
      else
        warn "Yahoo Geocoding API error: #{doc['responsecode']} (#{doc['reason']})."
        return []
      end
    end

    def query_url_params(query)
      super.merge(
        :location => query.sanitized_text,
        :flags => "JXTSR",
        :gflags => "AC#{'R' if query.reverse_geocode?}"
      )
    end

    def cache_key(query)
      raw_url(query)
    end

    def base_url
      "#{protocol}://yboss.yahooapis.com/geo/placefinder?"
    end

    def raw_url(query)
      base_url + url_query_string(query)
    end

    def query_url(query)
      parsed_url = URI.parse(raw_url(query))
      o = OauthUtil.new
      o.consumer_key = Geocoder::Configuration.api_key[0]
      o.consumer_secret = Geocoder::Configuration.api_key[1]
      base_url + o.sign(parsed_url).query_string
    end
  end
end
