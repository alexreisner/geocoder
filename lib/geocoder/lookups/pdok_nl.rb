require 'geocoder/lookups/base'
require "geocoder/results/pdok_nl"

module Geocoder::Lookup
  class PdokNl < Base

    def name
      'pdok NL'
    end

    def supported_protocols
      [:https]
    end

    private # ---------------------------------------------------------------

    def cache_key(query)
      base_query_url(query) + hash_to_query(query_url_params(query))
    end

    def base_query_url(query)
      "#{protocol}://api.pdok.nl/bzk/locatieserver/search/v3_1/free?"
    end

    def valid_response?(response)
      json   = parse_json(response.body)
      super(response) if json
    end

    def results(query)
      return [] unless doc = fetch_data(query)
      return doc['response']['docs']
    end

    def query_url_params(query)
      {
        fl: '*',
        q:  query.text,
        wt: 'json'
      }.merge(super)
    end
  end
end
