require 'geocoder/lookups/base'
require 'geocoder/results/azure'

module Geocoder::Lookup
  class Azure < Base
    def name
      'Azure'
    end

    def required_api_key_parts
      ['api_key']
    end

    def supported_protocols
      [:https]
    end

    private

    def base_query_url(query)
      host      = 'atlas.microsoft.com/search/address'
      url       = if query.reverse_geocode?
                    "#{protocol}://#{host}/reverse/json"
                  else
                    "#{protocol}://#{host}/json"
                  end
      params    = "?subscription-key=#{configuration.api_key}&api-version=1.0&query=#{query.sanitized_text}&limit=#{configuration.limit}"

      url + params
    end

    def results(query)
      return [] unless (doc = fetch_data(query))

      return doc if doc['error']

      if doc['results']&.any?
        doc['results']
      elsif doc['addresses']&.any?
        doc['addresses']
      else
        []
      end
    end
  end
end