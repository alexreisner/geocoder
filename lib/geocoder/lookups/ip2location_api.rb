require 'geocoder/lookups/base'
require 'geocoder/results/ip2location_api'

module Geocoder::Lookup
  class Ip2locationApi < Base

    def name
      "IP2LocationApi"
    end

    def query_url(query)
      api_key = configuration.api_key ? configuration.api_key : "demo"
      url_ = "#{protocol}://api.ip2location.com/?ip=#{query.sanitized_text}&key=#{api_key}&format=json"

      if (params = url_query_string(query)) && !params.empty?
        url_ + "&" + params
      else
        url_
      end
    end

    def supported_protocols
      [:http, :https]
    end

    private

    def results(query)
      return [reserved_result(query.text)] if query.loopback_ip_address?

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
        "country_code"         => "INVALID IP ADDRESS",
        "country_name"         => "INVALID IP ADDRESS",
        "region_name"          => "INVALID IP ADDRESS",
        "city_name"            => "INVALID IP ADDRESS",
        "latitude"             => "INVALID IP ADDRESS",
        "longitude"            => "INVALID IP ADDRESS",
        "zip_code"             => "INVALID IP ADDRESS",
        "time_zone"            => "INVALID IP ADDRESS",
        "isp"                  => "INVALID IP ADDRESS",
        "domain"               => "INVALID IP ADDRESS",
        "net_speed"            => "INVALID IP ADDRESS",
        "idd_code"             => "INVALID IP ADDRESS",
        "area_code"            => "INVALID IP ADDRESS",
        "weather_station_code" => "INVALID IP ADDRESS",
        "weather_station_name" => "INVALID IP ADDRESS",
        "mcc"                  => "INVALID IP ADDRESS",
        "mnc"                  => "INVALID IP ADDRESS",
        "mobile_brand"         => "INVALID IP ADDRESS",
        "elevation"            => "INVALID IP ADDRESS",
        "usage_type"           => "INVALID IP ADDRESS"
      }
    end

    def query_url_params(query)
      params = {}
      params.merge!(package: configuration[:package]) if configuration.has_key?(:package)
      params.merge(super)
    end

  end
end
