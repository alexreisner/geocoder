require 'geocoder/lookups/base'
require 'geocoder/results/ipinfo_io'

module Geocoder::Lookup
  class IpinfoIo < Base

    def name
      "Ipinfo.io"
    end

    def query_url(query)
      "#{protocol}://ipinfo.io/#{query.sanitized_text}/geo"
    end

    # currently doesn't support HTTPS
    def supported_protocols
      [:http]
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
      {"message" => "Input string is not a valid IP address", "code" => 401}
    end

  end
end
