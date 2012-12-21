require 'geocoder/lookups/base'
require 'geocoder/results/maxmind'
require 'csv'

module Geocoder::Lookup
  class Maxmind < Base

    def name
      "MaxMind"
    end

    private # ---------------------------------------------------------------

    def results(query)
      # don't look up a loopback address, just return the stored result
      return [reserved_result] if query.loopback_ip_address?
      doc = fetch_data(query)
      if doc and doc.is_a?(Array)
        if doc.size == 10
          return [doc]
        elsif doc.size > 10 and doc[10] == "INVALID_LICENSE_KEY"
          raise_error(Geocoder::InvalidApiKey) ||
            warn("Invalid MaxMind API key.")
        end
      end
      return []
    end

    def parse_raw_data(raw_data)
      # Maxmind just returns text/plain as csv format but according to documentation,
      # we get ISO-8859-1 encoded string. We need to convert it.
      if raw_data.respond_to?(:force_encoding)
        raw_data = raw_data.force_encoding("ISO-8859-1").encode("UTF-8")
      end
      CSV.parse_line raw_data
    end

    def reserved_result
      ",,,,0,0,0,0,,"
    end

    def query_url_params(query)
      super.merge(
        :l => configuration.api_key,
        :i => query.sanitized_text
      )
    end

    def query_url(query)
      "#{protocol}://geoip3.maxmind.com/f?" + url_query_string(query)
    end
  end
end
