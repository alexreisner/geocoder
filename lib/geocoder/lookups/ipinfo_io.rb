require 'geocoder/lookups/base'
require 'geocoder/results/ipinfo_io'

module Geocoder::Lookup
  class IpinfoIo < Base

    def name
      "Ipinfo.io"
    end

    def query_url(query)
      if configuration.api_key
        "#{protocol}://ipinfo.io/#{query.sanitized_text}/geo?" + url_query_string(query)
      else
        "#{protocol}://ipinfo.io/#{query.sanitized_text}/geo"
      end
    end

    # HTTPS available only for paid plans
    def supported_protocols
      if configuration.api_key
        [:http, :https]
      else
        [:http]
      end
    end

    private # ---------------------------------------------------------------

    def results(query)
      # don't look up a loopback address, just return the stored result
      return [reserved_result(query.text)] if query.loopback_ip_address?
      if (doc = fetch_data(query)).nil? or doc['code'] == 401 or empty_result?(doc)
        []
      else
        [doc]
      end
    end

    def empty_result?(doc)
      !doc.is_a?(Hash) or doc.keys == ["ip"]
    end

    def reserved_result(ip)
      {
        "ip"           => ip,
        "city"         => "",
        "region"       => "",
        "country"      => "",
        "loc"          => "0,0",
        "postal"       => ""
      }
    end

    def query_url_params(query)
      {
        token: configuration.api_key
      }.merge(super)
    end

  end
end
