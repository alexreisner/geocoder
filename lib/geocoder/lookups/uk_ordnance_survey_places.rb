require 'geocoder/lookups/base'
require 'geocoder/results/uk_ordnance_survey_places'

module Geocoder::Lookup
  class UkOrdnanceSurveyPlaces < Base

    def name
      'Ordance Survey Places'
    end

    def supported_protocols
      [:https]
    end

    def base_query_url(query)
      "#{protocol}://api.os.uk/search/places/v1/find?"
    end

    def required_api_key_parts
      ["key"]
    end

    def query_url(query)
      base_query_url(query) + url_query_string(query)
    end

    private # -------------------------------------------------------------

    def results(query)
      return [] unless doc = fetch_data(query)
      return [] if doc['header']['totalresults'].zero?
      doc['results'].map { |r| r.dig('DPA') || r.dig('LPI') }
    end

    def query_url_params(query)
      {
        query: query.sanitized_text,
        key: configuration.api_key,
        dataset: 'DPA,LPI',
        output_srs: 'EPSG:4326',
        maxresults: 10
      }.merge(super)
    end
  end
end
