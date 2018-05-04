require 'geocoder/lookups/base'
require 'geocoder/results/ipstack'

module Geocoder::Lookup
  class Ipstack < Base

    ERROR_CODES = {
      404 => Geocoder::InvalidRequest,
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
      "Ipstack"
    end

    def query_url(query)
      extra_params = url_query_string(query)
      url = "#{protocol}://#{host}/#{query.sanitized_text}?access_key=#{api_key}"
      url << "&#{extra_params}" unless extra_params.empty?
      url
    end

    private

    def results(query)
      # don't look up a loopback address, just return the stored result
      return [reserved_result(query.text)] if query.loopback_ip_address?

      return [] unless doc = fetch_data(query)

      if error = doc['error']
        code = error['code']
        msg = error['info']
        raise_error(ERROR_CODES[code], msg ) || Geocoder.log(:warn, "Ipstack Geocoding API error: #{msg}")
        return []
      end
      [doc]
    end

    def reserved_result(ip)
      {
        "ip"           => ip,
        "country_name" => "Reserved",
        "country_code" => "RD"
      }
    end

    def host
      configuration[:host] || "api.ipstack.com"
    end

    def api_key
      configuration.api_key
    end
  end
end
