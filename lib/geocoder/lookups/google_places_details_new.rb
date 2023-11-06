require 'geocoder/lookups/google_new'
require 'geocoder/results/google_places_details_new'

module Geocoder::Lookup
  class GooglePlacesDetailsNew < GoogleNew
    def name
      'Google Placees Details (New)'
    end

    private

    def base_query_url(query)
      "#{base_url}/#{query.text}?"
    end

    def results(query)
      result = super(query)
      return [result] unless result.is_a? Array

      result
    end

    def fields(query)
      if query.options.has_key?(:fields)
        return format_fields(query.options[:fields])
      end

      if configuration.has_key?(:fields)
        return format_fields(configuration[:fields])
      end

      # Google discourage the use of the wildcard field mask so you probably do NOT want to use it
      '*'
    end

    def format_fields(*fields)
      flattened = fields.flatten.compact
      return if flattened.empty?

      flattened.join(',')
    end

    def query_url_google_params(query)
      {
        fields: fields(query),
        languageCode: query.language || configuration.language
      }.merge(super)
    end
  end
end
