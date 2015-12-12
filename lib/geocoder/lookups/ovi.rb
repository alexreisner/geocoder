require 'geocoder/lookups/base'
require 'geocoder/results/ovi'

module Geocoder::Lookup
  class Ovi < Base

    def name
      "Ovi".freeze
    end

    def required_api_key_parts
      []
    end

    def query_url(query)
      reverse = query.reverse_geocode? ? 'reverse' : ''
      "#{protocol}://lbs.ovi.com/search/6.2/#{reverse}geocode.json?#{url_query_string(query)}"
    end

    private

    def results(query)
      return [] unless doc = fetch_data(query)

      view = doc.fetch('Response', {})['View']
      view.is_a?(Array) && view.any? ? view.first['Result'] : []
    end

    def query_url_params(query)
      options = {
        gen: 1,
        app_id: api_key,
        app_code: api_code
      }

      if query.reverse_geocode?
        options[:prox] = query.sanitized_text
        options[:mode] = :retrieveAddresses
      else
        options[:searchtext] = query.sanitized_text
      end

      super.merge(options)
    end

    def api_key
      api = configuration.api_key
      api.first if api.is_a?(Array)
    end

    def api_code
      api = configuration.api_key
      api.last if api.is_a?(Array)
    end
  end
end
