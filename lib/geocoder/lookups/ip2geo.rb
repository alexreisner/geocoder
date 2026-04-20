require 'geocoder/lookups/base'
require 'geocoder/results/ip2geo'

module Geocoder::Lookup
  class Ip2geo < Base

    def name
      "ip2geo"
    end

    def required_api_key_parts
      ["api_key"]
    end

    def supported_protocols
      [:https]
    end

    def query_url(query)
      "#{protocol}://#{host}/convert?#{url_query_string(query)}"
    end

    private # ---------------------------------------------------------------

    def results(query)
      # Don't look up a loopback or private address, just return the stored result.
      return [reserved_result(query.text)] if query.internal_ip_address?

      return [] unless (doc = fetch_data(query))
      return [] unless doc['success']
      return [] unless (data = doc['data'])

      [data]
    end

    def reserved_result(ip)
      {
        "ip"        => ip,
        "type"      => "reserved",
        "is_eu"     => false,
        "continent" => {
          "name" => "",
          "code" => "",
          "country" => {
            "name"       => "Reserved",
            "code"       => "RD",
            "phone_code" => "",
            "capital"    => "",
            "tld"        => "",
            "flag"       => { "emoji" => "", "img" => "" },
            "currency"   => { "name" => "", "code" => "", "symbol" => "" },
            "subdivision" => { "name" => "", "code" => "" },
            "city" => {
              "name"            => "",
              "latitude"        => 0,
              "longitude"       => 0,
              "postal_code"     => "",
              "geoname_id"      => nil,
              "accuracy_radius" => nil,
              "timezone"        => { "name" => "", "time_now" => "" }
            }
          }
        },
        "asn"                => { "number" => nil, "name" => "" },
        "registered_country" => { "name" => "", "code" => "" }
      }
    end

    def query_url_params(query)
      { ip: query.sanitized_text }.merge(super)
    end

    # Inject the X-Api-Key header automatically so users only need to set
    # api_key in their Geocoder configuration.
    def make_api_request(query)
      configuration.http_headers["X-Api-Key"] ||= configuration.api_key
      super
    end

    def host
      configuration[:host] || "api.ip2geo.dev"
    end

    def cache_key(query)
      query_url(query)
    end

    def check_response_for_errors!(response)
      case response.code.to_i
      when 401
        raise_error(Geocoder::InvalidApiKey) ||
          Geocoder.log(:warn, "ip2geo API error: invalid or missing API key")
      when 403
        raise_error(Geocoder::RequestDenied) ||
          Geocoder.log(:warn, "ip2geo API error: request denied")
      when 429
        raise_error(Geocoder::OverQueryLimitError) ||
          Geocoder.log(:warn, "ip2geo API error: rate limit exceeded")
      else
        super(response)
      end
    end
  end
end
