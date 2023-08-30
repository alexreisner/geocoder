require 'geocoder/lookups/base'
require 'geocoder/results/ip2location_io'

module Geocoder::Lookup
  class Ip2locationIo < Base

    def name
      "IP2LocationIOApi"
    end

    def required_api_key_parts
      ['key']
    end

    def supported_protocols
      [:http, :https]
    end

    private # ----------------------------------------------------------------

    def base_query_url(query)
      "#{protocol}://api.ip2location.io/?"
    end

    def query_url_params(query)
      super.merge(
        key: configuration.api_key,
        ip: query.sanitized_text,
      )
    end

    def results(query)
      # don't look up a loopback or private address, just return the stored result
      return [reserved_result(query.text)] if query.internal_ip_address?
      return [] unless doc = fetch_data(query)
      if doc["response"] == "INVALID ACCOUNT"
        raise_error(Geocoder::InvalidApiKey) || Geocoder.log(:warn, "INVALID ACCOUNT")
        return []
      else
        return [doc]
      end
    end

    def reserved_result(query)
      {
        "ip"           => "-",
        "country_code" => "-",
        "country_name" => "-",
        "region_name"  => "-",
        "city_name"    => "-",
        "latitude"     => null,
        "longitude"    => null,
        "zip_code"     => "-",
        "time_zone"    => "-",
        "asn"          => "-",
        "as"           => "-",
        "is_proxy"     => false
      }
    end

  end
end
