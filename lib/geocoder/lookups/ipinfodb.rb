require 'geocoder/lookups/base'
require 'geocoder/results/ipinfodb'

module Geocoder::Lookup
  class Ipinfodb < Base

    def name
      "IPInfoDBApi"
    end

    def query_url(query)
      url = "#{protocol}://api.ipinfodb.com/v3/ip-city/?key=#{configuration.api_key}&ip=#{query.sanitized_text}&format=json"
    end

    def supported_protocols
      [:http, :https]
    end

    private # ----------------------------------------------------------------

    def results(query)
      return [reserved_result(query.text)] if query.loopback_ip_address?
      return [] unless doc = fetch_data(query)
      if doc["statusMessage"] == "Invalid API key."
        raise_error(Geocoder::InvalidApiKey) || Geocoder.log(:warn, "Invalid API key.")
        return []
      else
        return [doc]
      end
    end

    def reserved_result(query)
      {
        "countryCode"         => "-",
        "countryName"         => "-",
        "regionName"          => "-",
        "cityName"            => "-",
        "zipCode"             => "-",
        "latitude"            => "0",
        "longitude"           => "0",
        "timeZone"            => "-"
      }
    end

  end
end
