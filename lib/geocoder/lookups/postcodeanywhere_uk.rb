require 'geocoder/lookups/base'
require 'geocoder/results/postcodeanywhere_uk'

module Geocoder::Lookup
  class PostcodeanywhereUk < Base
    def name
      'Postcodeanywhere UK'
    end

    def query_url(query)
      "#{protocol}://services.postcodeanywhere.co.uk/Geocoding/UK/Geocode/v2.00/json3.ws?" + url_query_string(query)
    end

    private # ---------------------------------------------------------------

    def results(query)
      return [] unless doc = fetch_data(query)

      first_item = doc['Items'].first
      if first_item && (error = first_item['Error'])
        case error
        when '2', '3'
          raise_error(Geocoder::InvalidRequest, first_item['Cause']) || warn(first_item['Cause'])
        else
          raise_error(Geocoder::RequestDenied, first_item['Cause']) || warn(first_item['Cause'])
        end
      end

      doc['Items']
    end

    def query_url_params(query)
      {
        'Key' => configuration.api_key,
        'Country' => 'UK',
        'Location' => query.sanitized_text
      }.merge(super)
    end
  end
end