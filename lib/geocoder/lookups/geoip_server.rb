require 'geocoder/lookups/base'
require 'geocoder/results/geoip_server'

module Geocoder::Lookup
  class GeoipServer < Base

    private # ---------------------------------------------------------------

    def results(query)
      # don't look up a loopback address, just return the stored result
      return [reserved_result(query.text)] if query.loopback_ip_address?
      doc = fetch_data(query)
      (doc && doc != {}) ? [ doc ] : []
    end

    def reserved_result(ip)
      {
        "ip"                => ip,
        "ip_lookup"         => ip,
        "country_code"      => "RD",
        "country_code_long" => "RD",
        "country"           => "Reserved",
        "continent"         => "",
        "region"            => "",
        "city"              => "",
        "postal_code"       => "",
        "lat"               => "0",
        "lng"               => "0",
        "dma_code"          => "",
        "area_code"         => "",
        "timezone"          => ""
      }
    end

    def query_url(query)
      "#{protocol}://#{Geocoder::Configuration.ip_lookup_host}/#{query.sanitized_text}"
    end
  end
end
