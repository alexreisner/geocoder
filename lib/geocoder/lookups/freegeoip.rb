require 'geocoder/lookups/base'
require 'geocoder/results/freegeoip'

module Geocoder::Lookup
  class Freegeoip < Base

    private # ---------------------------------------------------------------

    def results(query, reverse = false)
      begin
        if doc = fetch_data(query, reverse)
          [doc]
        end
      rescue StandardError # Freegeoip.net returns HTML on bad request
        nil
      end
    end

    def query_url(query, reverse = false)
      "http://freegeoip.net/json/#{query}"
    end
  end
end
