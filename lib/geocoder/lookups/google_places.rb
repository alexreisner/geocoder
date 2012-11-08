require 'geocoder/lookups/base'
require "geocoder/results/google_places"

module Geocoder::Lookup
  class GooglePlaces < Base

  private

    def results(query)
      return [] unless doc = fetch_data(query)

      case doc['status']; when "OK" # OK status implies >0 results
        return doc['results']
      when "OVER_QUERY_LIMIT"
        raise_error(Geocoder::OverQueryLimitError) ||
          warn("Google Geocoding API error: over query limit.")
      when "REQUEST_DENIED"
        raise_error(Geocoder::RequestDenied) ||
          warn("Google Geocoding API error: request denied.")
      when "INVALID_REQUEST"
        raise_error(Geocoder::InvalidRequest) ||
          warn("Google Geocoding API error: invalid request.")
      end
      return []
    end

    def query_url_google_params(query)
      params = {
        :sensor => "false",
        :language => Geocoder::Configuration.language,
        :query => query.sanitized_text
      }


      unless (bounds = query.options[:bounds]).nil?
        params[:bounds] = bounds.map{ |point| "%f,%f" % point }.join('|')
      end
      params
    end

    def query_url_params(query)
      super.merge(query_url_google_params(query)).merge(
        :key => Geocoder::Configuration.api_key
      )
    end

    def query_url(query)
      "#{protocol}://maps.googleapis.com/maps/api/place/textsearch/json?" + url_query_string(query)
    end
  end
end

