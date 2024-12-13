require 'geocoder/lookups/base'
require 'geocoder/results/get_address_uk'

module Geocoder::Lookup
  class GetAddressUk < Base
    # Documentation: https://getaddress.io/Documentation

    def name
      'GetAddressUk'
    end

    private

    def base_query_url(query)
      "#{protocol}://api.getaddress.io/v2/uk/#{query.to_s.split.join}?api-key=#{configuration.api_key}"
    end

    def supported_protocols
      [:https]
    end

    def results(query)
      response = fetch_data query
      return [] if response.nil? || !response.is_a?(Hash) || response.empty?
      if response['Message']
        raise_exception_for_response response
        return []
      end
      [response]
    end

    def raise_exception_for_response(response)
      return if response['Message'] == 'Not Found'
      case response['Message']
        when 'Bad Request'
          raise_error(Geocoder::InvalidRequest, response['Message']) ||
            Geocoder.log(:warn, 'getaddress.io error: Your postcode is not valid')
        when 'Unauthorized'
          raise_error(Geocoder::InvalidApiKey) ||
            Geocoder.log(:warn, 'Invalid getaddress.io API key.')
        when 'Too Many Requests'
          raise_error(Geocoder::OverQueryLimitError) ||
            Geocoder.log(:warn, 'getaddress.io error: You have made more requests than your allowed limit.')
        when 'Internal Server Error'
          raise_error(Geocoder::ServiceUnavailable) ||
            Geocoder.log(:warn, 'getaddress.io error: Internal Server Error.')
        else # anything else just raise general error with the api message
          raise_error(Geocoder::Error, response['Message']) ||
            Geocoder.log(:warn, response['Message'])
      end
    end
  end
end
