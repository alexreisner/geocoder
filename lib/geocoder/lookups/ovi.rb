# ovi.com store

require 'geocoder/lookups/base'
require "geocoder/results/ovi"

module Geocoder::Lookup
  class Ovi < Base

    private # ---------------------------------------------------------------

    def results(query)
      return [] unless doc = fetch_data(query)
      return [] unless doc['Response']
      doc['Response']['View'].first['Result']
    end

    def query_url_params(query)
      super.merge(
        :searchtext => query.sanitized_text
      )
    end

    def query_url(query)
      "http://lbs.ovi.com/search/6.2/geocode.json?" + url_query_string(query)
    end
  end
end
