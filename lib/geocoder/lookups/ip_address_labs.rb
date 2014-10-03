require 'geocoder/lookups/base'
require 'geocoder/results/ip_address_labs'
require 'csv'

module Geocoder::Lookup
  class IpAddressLabs < Base

    def name
      "IpAddressLabs"
    end

    def query_url(query)
      "#{protocol}://api.ipaddresslabs.com/iplocation/v1.7/locateip?key=#{configuration[:api_key]}&ip=#{query}&format=JSON"
    end

    def reserved_result
      {
        "city"         => "New York",
        "region_code"  => "NY",
        "latitude"     => 40.7127837,
        "longitude"    => -74.0059413
      }
    end

    private # ---------------------------------------------------------------


    def results(query)
      # don't look up a loopback address, just return the stored result
      return [reserved_result] if query.loopback_ip_address?
      doc = fetch_data(query)
      status = doc["query_status"]["query_status_code"]
      message = doc["query_status"]["query_status_description"]

      if status == "OK"
        return [ doc["geolocation_data"] ]
      else
        warn("IP Address Labs API Error: #{message}")
        []
      end
    end
  end
end
