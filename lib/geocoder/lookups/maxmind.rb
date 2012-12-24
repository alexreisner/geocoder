require 'geocoder/lookups/base'
require 'geocoder/results/maxmind'
require 'csv'

module Geocoder::Lookup
  class Maxmind < Base

    def name
      "MaxMind"
    end

    def query_url(query)
      "#{protocol}://geoip.maxmind.com/#{service_code}?" + url_query_string(query)
    end

    private # ---------------------------------------------------------------

    def service_code
      if s = configuration[:service] and services.keys.include?(s)
        services[s]
      else
        raise(
          Geocoder::ConfigurationError,
          "When using MaxMind you MUST specify a service name: " +
          "Geocoder.configure(:maxmind => {:service => ...}), " +
          "where '...' is one of: #{services.keys.inspect}"
        )
      end
    end

    ##
    # Service names mapped to code used in URL.
    #
    def services
      {
        :country => "a",
        :city => "b",
        :city_isp_org => "f",
        :omni => "e"
      }
    end

    def results(query)
      # don't look up a loopback address, just return the stored result
      return [reserved_result] if query.loopback_ip_address?
      doc = fetch_data(query)
      if doc and doc.is_a?(Array)
        if doc.last.nil?
          return [doc]
        elsif doc.last == "INVALID_LICENSE_KEY"
          raise_error(Geocoder::InvalidApiKey) || warn("Invalid MaxMind API key.")
        end
      end
      return []
    end

    def parse_raw_data(raw_data)
      CSV.parse_line raw_data
    end

    def reserved_result
      ",,,,0,0,0,0,,,"
    end

    def query_url_params(query)
      {
        :l => configuration.api_key,
        :i => query.sanitized_text
      }.merge(super)
    end
  end
end
