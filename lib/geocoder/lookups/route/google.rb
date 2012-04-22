#encode: utf-8

require 'geocoder/results/route/google'


# Documentation:
# - geocoding: https://developers.google.com/maps/documentation/geocoding/
# - routes:    https://developers.google.com/maps/documentation/directions/
module Geocoder::Lookup
  module Route
    module Google
      def route_results(points, options)
        return [] unless doc = route_fetch_data(points, options)
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
      
      # ----------------------------------------------------------------
      
      def route_query_url(points, options)
        params = {
          :origin => points.first,
          :destination => points.last,
          :waypoints => (points.size == 2)? nil : points[1..-2].join(','),
          :units => :metric,
          :sensor => 'false',
          :language => Geocoder::Configuration.language
        }.merge(options).reject{ |key, value| value.nil? }

        path = "/maps/api/directions/json?#{hash_to_query(params)}"

        # puts "#{protocol}://maps.googleapis.com#{path}"
        "#{protocol}://maps.googleapis.com#{path}"
      end
    end
  end
end