require 'geocoder/lookups/nominatim'
require "geocoder/results/locationiq"

module Geocoder::Lookup
  class Locationiq < Nominatim
    def name
      "Locationiq"
    end

    def required_api_key_parts
      ["api_key"]
    end
    
    def query_url(query)
      method = query.reverse_geocode? ? "reverse.php" : "search.php"
      host = configuration[:host] || "locationiq.org/v1"
      "#{protocol}://#{host}/#{method}?key=#{configuration.api_key}&" + url_query_string(query)
    end
  end
end
