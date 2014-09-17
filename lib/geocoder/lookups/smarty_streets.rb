require 'geocoder/lookups/base'
require 'geocoder/results/smarty_streets'

module Geocoder::Lookup
  class SmartyStreets < Base
    def name
      "SmartyStreets"
    end

    def required_api_key_parts
      %w(auti-id auth-token)
    end

    def query_url(query)
      path = zipcode_only?(query) ? "zipcode" : "street-address"
      "#{protocol}://api.smartystreets.com/#{path}?#{url_query_string(query)}"
    end

    private # ---------------------------------------------------------------

    def zipcode_only?(query)
      !query.text.is_a?(Array) and query.to_s.strip =~ /\A\d{5}(-\d{4})?\Z/
    end

    def query_url_params(query)
      params = {}
      if zipcode_only?(query)
        params[:zipcode] = query.sanitized_text
      else
        params[:street] = query.sanitized_text
      end
      if configuration.api_key.is_a?(Array)
        params[:"auth-id"] = configuration.api_key[0]
        params[:"auth-token"] = configuration.api_key[1]
      else
        params[:"auth-token"] = configuration.api_key
      end
      params.merge(super)
    end

    def results(query)
      fetch_data(query) || []
    end
  end
end
