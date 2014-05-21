require 'geocoder/lookups/base'
require 'geocoder/results/postcode_anywhere_uk'

module Geocoder::Lookup
  class PostcodeAnywhereUk < Base

    BASE_URL_GEOCODE_V200 = 'services.postcodeanywhere.co.uk/Geocoding/UK/Geocode/v2.00/json.ws'

    def name
      'PostcodeAnywhereUk'
    end

    def required_api_key_parts
      %w(key)
    end

    def query_url(query)
      format('%s://%s?%s', protocol, BASE_URL_GEOCODE_V200, url_query_string(query))
    end

    private

    def results(query)
      response = fetch_data(query)
      return [] if response.nil? || !response.is_a?(Array) || response.empty?

      return response
    end

    def query_url_params(query)
      {
        :location => query.sanitized_text,
        :key => configuration.api_key
      }.merge(super)
    end
  end
end
