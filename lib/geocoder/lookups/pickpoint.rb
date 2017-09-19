require "geocoder/lookups/nominatim"
require "geocoder/results/pickpoint"

module Geocoder::Lookup
  class Pickpoint < Nominatim
    def name
      "Pickpoint"
    end

    def supported_protocols
      [:https]
    end

    def required_api_key_parts
      ["api_key"]
    end

    def query_url(query)
      method = query.reverse_geocode? ? "reverse" : "forward"
      "#{protocol}://api.pickpoint.io/v1/#{method}?key=#{configuration.api_key}&" + url_query_string(query)
    end

    private

    def results(query)
      return [] unless doc = fetch_data(query)

      if !doc.is_a?(Array) && doc['message'] == 'Unauthorized'
        raise_error(Geocoder::InvalidApiKey, 'Unauthorized')
      end

      doc.is_a?(Array) ? doc : [doc]
    end
  end
end
