require 'geocoder/lookups/base'
require "geocoder/results/okf"

module Geocoder::Lookup
  class Okf < Base

    def name
      "Okf"
    end

    def query_url(query)
      "#{protocol}://data.okf.fi/gis/1/geocode/json?" + url_query_string(query)
    end

    private # ---------------------------------------------------------------

    def valid_response?(response)
      json = parse_json(response.body)
      status = json["status"] if json
      super(response) and ['OK', 'ZERO_RESULTS'].include?(status)
    end

    def results(query)
      return [] unless doc = fetch_data(query)
      case doc['status']; when "OK" # OK status implies >0 results
        return doc['results']
      end
      return []
    end

    def query_url_okf_params(query)
      params = {
        (query.reverse_geocode? ? :latlng : :address) => query.sanitized_text,
        :sensor => "false",
        :language => (query.language || configuration.language)
      }
      params
    end

    def query_url_params(query)
      query_url_okf_params(query).merge(super)
    end
  end
end
