require 'geocoder/lookups/base'
require 'geocoder/results/internetdata'

module Geocoder::Lookup
  class Internetdata < Base
    def name
      'InternetData'
    end

    # The API refuses a key sent over plain HTTP.
    def supported_protocols
      [:https]
    end

    private # ---------------------------------------------------------------

    def base_query_url(query)
      url = "#{protocol}://api.internetdata.io/#{query.sanitized_text}"
      url << '?' if configuration.api_key
      url
    end

    def results(query)
      # don't look up a loopback or private address, just return the stored result
      return [reserved_result(query.text)] if query.internal_ip_address?

      if !(doc = fetch_data(query)).is_a?(Hash) or doc['error']
        []
      else
        [doc]
      end
    end

    def reserved_result(ip)
      {
        'ip' => ip,
        'is_bogon' => true
      }
    end

    def query_url_params(query)
      {
        apikey: configuration.api_key
      }.merge(super)
    end
  end
end
