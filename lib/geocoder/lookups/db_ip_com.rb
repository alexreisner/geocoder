require 'geocoder/lookups/base'
require 'geocoder/results/db_ip_com'

module Geocoder::Lookup
  class DbIpCom < Base

    def name
      'DB-IP.com'
    end

    def supported_protocols
      [:https, :http]
    end

    def required_api_key_parts
      ['api_key']
    end

    def query_url(query)
      query_params = if query.options[:params]
        "?#{url_query_string(query)}"
      end

      "#{protocol}://api.db-ip.com/v2/#{configuration.api_key}/#{query.sanitized_text}#{query_params}"
    end

    private

    def results(query)
      return [] unless doc = fetch_data(query)

      if doc['error']
        if doc['error'] == 'invalid API key'
          raise_error(Geocoder::InvalidApiKey) || Geocoder.log(:warn, 'Invalid DB-IP API key.')
        else
          Geocoder.log(:warn, "DB-IP Geocoding API error: #{doc['error']}.")
        end

        return []
      else
        return [ doc ]
      end
    end
  end
end
