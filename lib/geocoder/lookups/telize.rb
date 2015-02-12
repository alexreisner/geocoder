require 'geocoder/lookups/base'
require 'geocoder/results/telize'

module Geocoder::Lookup
  class Telize < Base

    def name
      "Telize"
    end

    def query_url(query)
      #currently doesn't support HTTPS
      "http://www.telize.com/geoip/#{query.sanitized_text}"
    end

    private # ---------------------------------------------------------------

    def use_ssl?
      false
    end

    def results(query)
      # don't look up a loopback address, just return the stored result
      return [reserved_result(query.text)] if query.loopback_ip_address?
      if (doc = fetch_data(query)).nil? or doc['code'] == 401 or empty_result?(doc)
        []
      else
        [doc]
      end
    end

    def empty_result?(doc)
      !doc.is_a?(Hash) or doc.keys == ["ip"]
    end

    def reserved_result(ip)
      {"message" => "Input string is not a valid IP address", "code" => 401}
    end
  end
end
