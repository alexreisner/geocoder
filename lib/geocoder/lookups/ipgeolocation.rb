require 'geocoder/lookups/base'
require 'geocoder/results/ipgeolocation'


module Geocoder::Lookup
  class Ipgeolocation < Base

    ERROR_CODES = {
        404 => Geocoder::InvalidRequest,
        401 => Geocoder::RequestDenied, # missing/invalid API key
        101 => Geocoder::InvalidApiKey,
        102 => Geocoder::Error,
        103 => Geocoder::InvalidRequest,
        104 => Geocoder::OverQueryLimitError,
        105 => Geocoder::RequestDenied,
        301 => Geocoder::InvalidRequest,
        302 => Geocoder::InvalidRequest,
        303 => Geocoder::RequestDenied,
    }
    ERROR_CODES.default = Geocoder::Error

    def name
      "Ipgeolocation"
    end

    def supported_protocols
      [:https]
    end

    private # ----------------------------------------------------------------

    def base_query_url(query)
      "#{protocol}://api.ipgeolocation.io/ipgeo?"
    end
    def query_url_params(query)
      {
          ip: query.sanitized_text,
          apiKey: configuration.api_key
      }.merge(super)
    end

    def results(query)
      # don't look up a loopback or private address, just return the stored result
      return [reserved_result(query.text)] if query.internal_ip_address?
      return [] unless doc = fetch_data(query)
      if error = doc['error']
        code = error['code']
        msg = error['info']
        raise_error(ERROR_CODES[code], msg ) || Geocoder.log(:warn, "Ipgeolocation Geocoding API error: #{msg}")
        return []
      end
      [doc]
    end

    def reserved_result(ip)
      {
          "ip"           => ip,
          "country_name" => "Reserved",
          "country_code2" => "RD"
      }
    end
  end
end
