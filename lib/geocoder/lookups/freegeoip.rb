require 'geocoder/lookups/base'
require 'geocoder/results/freegeoip'

module Geocoder::Lookup
  class Freegeoip < Base

    def name
      "FreeGeoIP"
    end
    
    def supported_protocols
      [:http]
    end

    def query_url(query)
      "#{protocol}://#{host}/json/#{query.sanitized_text}"
    end

    private # ---------------------------------------------------------------

    def parse_raw_data(raw_data)
      raw_data.match(/^<html><title>404/) ? nil : super(raw_data)
    end

    def results(query)
      # don't look up a loopback address, just return the stored result
      return [reserved_result(query.text)] if query.loopback_ip_address?
      # note: Freegeoip.net returns plain text "Not Found" on bad request
      (doc = fetch_data(query)) ? [doc] : []
    end

    def reserved_result(ip)
      {
        "ip"           => ip,
        "city"         => "",
        "region_code"  => "",
        "region_name"  => "",
        "metrocode"    => "",
        "zipcode"      => "",
        "latitude"     => "0",
        "longitude"    => "0",
        "country_name" => "Reserved",
        "country_code" => "RD"
      }
    end

    def host
      configuration[:host] || "freegeoip.io"
    end
  end
end
