require 'geocoder/lookups/base'
require 'geocoder/results/freegeoip'

module Geocoder::Lookup
  class Freegeoip < Base

    def name
      "FreeGeoIP"
    end

    def query_url(query)
      "#{protocol}://freegeoip.net/json/#{query.sanitized_text}"
    end

    private # ---------------------------------------------------------------

    def parse_raw_data(raw_data)
      raw_data.match(/^<html><title>404/) ? nil : super(raw_data)
    end

    def results(query)
      # don't look up a loopback address, just return the stored result
      return [reserved_result(query.text)] if query.loopback_ip_address?
      begin
        return (doc = fetch_data(query)) ? [doc] : []
      rescue StandardError => err # Freegeoip.net returns HTML on bad request
        raise_error(err)
        return []
      end
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
  end
end
