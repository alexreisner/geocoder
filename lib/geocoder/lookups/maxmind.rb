require 'geocoder/lookups/base'
require 'geocoder/results/maxmind'
require 'csv'

module Geocoder::Lookup
  class Maxmind < Base

    private # ---------------------------------------------------------------

    def results(query, reverse = false)
      # don't look up a loopback address, just return the stored result
      return [reserved_result] if loopback_address?(query)
      begin
        doc = fetch_data(query, reverse)
        if doc && doc.size == 10
          return [doc]
        else
          warn "Maxmind error : #{doc[10]}" if doc
          return []
        end
      rescue StandardError => err
        raise_error(err)
        return []
      end
    end

    def parse_raw_data(raw_data)
      # Maxmind just returns text/plain as csv format but according to documentation,
      # we get ISO-8859-1 encoded string. We need to convert it.
      CSV.parse_line raw_data.force_encoding("ISO-8859-1").encode("UTF-8")
    end

    def reserved_result
      ",,,,0,0,0,0,,"
    end

    def query_url(query, reverse = false)
      "http://geoip3.maxmind.com/f?l=#{Geocoder::Configuration.ip_lookup_api_key}&i=#{query}"
    end
  end
end
