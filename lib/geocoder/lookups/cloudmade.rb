require 'geocoder/lookups/base'
require 'geocoder/results/cloudmade'

module Geocoder::Lookup
  class Cloudmade < Base

    def name
      "Cloudmade"
    end

    def query_url(query)
      "http://geocoding.cloudmade.com/#{configuration.api_key}/geocoding/v2/find.js?#{url_query_string(query)}"
    end

    def required_api_key_parts
      ["key"]
    end

    private

    def results(query)
      data = fetch_data(query)
      (data && data['features']) || []
    end

    def query_url_params(query)
      {
        :query => query.sanitized_text,
        :return_location => true,
        :return_geometry => false
      }.merge(super)
    end

  end
end
