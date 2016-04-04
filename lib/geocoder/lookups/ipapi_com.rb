require 'geocoder/lookups/base'
require 'geocoder/results/ipapi_com'

module Geocoder::Lookup
  class IpapiCom < Base

    def name
      "ip-api.com"
    end

    def query_url(query)
      url_ = "#{protocol}://ip-api.com/json/#{query.sanitized_text}"

      if (params = url_query_string(query)) && !params.empty?
        url_ + "?" + params
      else
        url_
      end
    end

    def supported_protocols
      if configuration.api_key
        [:http, :https]
      else
        [:http]
      end
    end


    private

    def results(query)
      return [reserved_result(query.text)] if query.loopback_ip_address?

      (doc = fetch_data(query)) ? [doc] : []
    end

    def reserved_result(query)
      {
        "message"      => "reserved range",
        "query"        => query,
        "status"       => fail,
        "ip"           => query,
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

    def query_url_params(query)
      params = {}
      params.merge!(fields: configuration[:fields]) if configuration.has_key?(:fields)
      params.merge!(key: configuration.api_key) if configuration.api_key
      params.merge(super)
    end

  end
end
