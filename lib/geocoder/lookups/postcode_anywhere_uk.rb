require 'geocoder/lookups/base'
require 'geocoder/results/postcode_anywhere_uk'

module Geocoder::Lookup
  class PostcodeAnywhereUk < Base

    BASE_URL_GEOCODE_V2_00 = 'services.postcodeanywhere.co.uk/Geocoding/UK/Geocode/v2.00/json.ws'

    def name
      'PostcodeAnywhereUk'
    end

    def required_api_key_parts
      %w(key)
    end

    def query_url(query)
      format('%s://%s?%s', protocol, BASE_URL_GEOCODE_V2_00, url_query_string(query))
    end

    private

    def results(query)
      response = fetch_data(query)
      return [] if response.nil? || !response.is_a?(Array) || response.empty?

      raise_exception_for_response(response[0]) if response[0]['Error']
      response
    end

    def raise_exception_for_response(response)
      case response['Error']
      when '8', '17' # api docs say these two codes are the same error
        raise_error(Geocoder::OverQueryLimitError, response['Cause']) || warn(response['Cause'])
      when '2'
        raise_error(Geocoder::InvalidApiKey, response['Cause']) || warn(response['Cause'])
      else # anything else just raise general error with the api cause
        raise_error(Geocoder::Error, response['Cause']) || warn(response['Cause'])
      end
    end

    def query_url_params(query)
      {
        :location => query.sanitized_text,
        :key => configuration.api_key
      }.merge(super)
    end
  end
end
