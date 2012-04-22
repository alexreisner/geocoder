require 'geocoder/lookups/base'
require "geocoder/results/google"

module Geocoder::Lookup
  class Google < Base

    def map_link_url(coordinates)
      "http://maps.google.com/maps?q=#{coordinates.join(',')}"
    end

    private # ---------------------------------------------------------------

    def results(query, options = {})
      return [] unless doc = fetch_data(query, options)
      case doc['status']; when "OK" # OK status implies >0 results
        return doc['results']
      when "OVER_QUERY_LIMIT"
        raise_error(Geocoder::OverQueryLimitError) ||
          warn("Google Geocoding API error: over query limit.")
      when "REQUEST_DENIED"
        warn "Google Geocoding API error: request denied."
      when "INVALID_REQUEST"
        warn "Google Geocoding API error: invalid request."
      end
      return []
    end

    def query_url(query, options = {})
      params = {
        (options[:reverse] ? :latlng : :address) => query,
        :sensor => "false",
        :language => Geocoder::Configuration.language,
        :key => Geocoder::Configuration.api_key
      }

      unless options[:bounds].nil?
        params[:bounds] = options[:bounds].map{ |point| "#{point[0]},#{point[1]}" }.join('|')
      end

      "#{protocol}://maps.googleapis.com/maps/api/geocode/json?" + hash_to_query(params)
    end
  end
end

