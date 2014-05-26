require 'geocoder/lookups/base'
require "geocoder/results/yahoo"
require 'oauth_util'

module Geocoder::Lookup
  class Yahoo < Base

    def name
      "Yahoo BOSS"
    end

    def map_link_url(coordinates)
      "http://maps.yahoo.com/#lat=#{coordinates[0]}&lon=#{coordinates[1]}"
    end

    def required_api_key_parts
      ["consumer key", "consumer secret"]
    end

    def query_url(query)
      parsed_url = URI.parse(raw_url(query))
      o = OauthUtil.new
      o.consumer_key = configuration.api_key[0]
      o.consumer_secret = configuration.api_key[1]
      base_url + o.sign(parsed_url).query_string
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

    ##
    # Yahoo returns errors as XML even when JSON format is specified.
    # Handle that here, without parsing the XML
    # (which would add unnecessary complexity).
    # Yahoo auth errors can also be cryptic, so add raw error desc
    # to warning message.
    #
    def parse_raw_data(raw_data)
      if raw_data.match(/^<\?xml/)
        if raw_data.include?("Rate Limit Exceeded")
          raise_error(Geocoder::OverQueryLimitError) || warn("Over API query limit.")
        elsif raw_data =~ /<yahoo:description>(Please provide valid credentials.*)<\/yahoo:description>/i
          raise_error(Geocoder::InvalidApiKey) || warn("Invalid API key. Error response: #{$1}")
        end
      else
        super(raw_data)
      end
    end

    def query_url_params(query)
      lang = (query.language || configuration.language).to_s
      lang += '_US' if lang == 'en'
      {
        :location => query.sanitized_text,
        :flags => "JXTSR",
        :gflags => "AC#{'R' if query.reverse_geocode?}",
        :locale => lang,
        :appid => configuration.api_key
      }.merge(super)
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
  end
end
