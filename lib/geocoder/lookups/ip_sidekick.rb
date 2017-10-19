require 'geocoder/lookups/base'
require 'geocoder/results/ip_sidekick'

module Geocoder::Lookup
  class IpSidekick < Base

    def name
      "IP Sidekick"
    end

    def query_url(query)
      if configuration.api_key
        "#{protocol}://ipsidekick.com/p/#{query.sanitized_text}?" + url_query_string(query)
      else
        "#{protocol}://ipsidekick.com/#{query.sanitized_text}"
      end.tap do |v|
        puts "url: #{v}"
      end
    end

    def supported_protocols
      [:https]
    end

    private # ---------------------------------------------------------------

    def results(query)
      return [reserved_result(query.text)] if query.loopback_ip_address?
      return [] unless doc = fetch_data(query)

      if doc and doc.is_a?(Hash)
        if !data_contains_error?(doc)
          return [doc]
        elsif doc['error']
          if doc['error'].start_with? "You have hit our rate limits"
            raise_error(Geocoder::OverQueryLimitError) || Geocoder.log(:warn, doc['error'])
          else
            raise_error(Geocoder::InvalidRequest) || Geocoder.log(:warn, doc['error'])
          end
        else
          raise_error(Geocoder::Error) || Geocoder.log(:warn, "IP Sidekick server error")
        end
      end
      return []
    end

    def data_contains_error?(parsed_data)
      parsed_data.keys.include?('error')
    end

    def empty_result?(doc)
      !doc.is_a?(Hash) or doc.keys == ["ip"]
    end

    def reserved_result(ip)
      {
        "ip"           => ip,
      }
    end

    def query_url_params(query)
      {
        apiKey: configuration.api_key
      }.merge(super)
    end

  end
end
