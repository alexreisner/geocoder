require 'openssl'
require 'base64'
require 'geocoder/lookups/google'
require 'geocoder/results/google_api_v3'
require 'geocoder/route_results/google_api_v3'


# Documentation:
# - geocoding: https://developers.google.com/maps/documentation/geocoding/
# - routes:    https://developers.google.com/maps/documentation/directions/
module Geocoder::Lookup
  class GoogleApiV3 < Google
  
    

    private # ---------------------------------------------------------------

    def route_results(origin, destination, options)
      return [] unless doc = route_fetch_data(origin, destination, options)
      case doc['status']; when "OK" # OK status implies >0 results
        return doc['routes']
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

    def query_url(query, reverse = false)
      params = {
        (reverse ? :latlng : :address) => query,
        :sensor => 'false',
        :language => Geocoder::Configuration.language
      }.reject{ |key, value| value.nil? }
      path = "/maps/api/geocode/json?#{hash_to_query(params)}"
      "#{protocol}://maps.googleapis.com#{path}"
    end

    def route_query_url(origin, destination, options)
      params = {
        :origin => origin,
        :destination => destination,
        :sensor => 'false',
        :language => Geocoder::Configuration.language
      }.merge(options).reject{ |key, value| value.nil? }
      path = "/maps/api/directions/json?#{hash_to_query(params)}"
      # puts "#{protocol}://maps.googleapis.com#{path}"
      "#{protocol}://maps.googleapis.com#{path}"
    end

    def url_safe_base64_decode(base64_string)
      Base64.decode64(base64_string.tr('-_', '+/'))
    end

    def url_safe_base64_encode(raw)
      Base64.encode64(raw).tr('+/', '-_').strip
    end
  end
end
