#encode: utf-8



module Geocoder::Lookup
  module Route
    module Bing
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
        waypoints = {}
        points.each_with_index do |point, index|
          waypoints["wp.#{index}"] = point
        end
        
        params = {
          :distanceUnit => :km,
          :sensor => 'false',
          :language => Geocoder::Configuration.language
        }.merge(options).merge(waypoints).reject{ |key, value| value.nil? }

        path = "/REST/V1/Routes/Driving?#{hash_to_query(params)}"

        # puts "#{protocol}://dev.virtualearth.net#{path}"
        "#{protocol}://dev.virtualearth.net#{path}"
      end
    end
  end
end