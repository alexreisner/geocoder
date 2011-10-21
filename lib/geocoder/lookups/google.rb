require 'geocoder/lookups/base'
require "geocoder/results/google"

module Geocoder::Lookup
  class Google < Base

    def map_link_url(coordinates)
      "http://maps.google.com/maps?q=#{coordinates.join(',')}"
    end

    private # ---------------------------------------------------------------

    def results(query, reverse_or_options = false)
      return [] unless doc = fetch_data(query, reverse_or_options)
      case doc['status']; when "OK" # OK status implies >0 results
        return doc['results']
      when "OVER_QUERY_LIMIT"
        warn "Google Geocoding API error: over query limit."
      when "REQUEST_DENIED"
        warn "Google Geocoding API error: request denied."
      when "INVALID_REQUEST"
        warn "Google Geocoding API error: invalid request."
      end
      return []
    end

    def query_url(query, reverse_or_options = false)
      reverse, options = extract_reverse_and_options(reverse_or_options)
      params = {
        (reverse ? :latlng : :address) => query,
        :sensor => "false",
        :language => Geocoder::Configuration.language,
        :key => Geocoder::Configuration.api_key
      }
      if options[:bounds]
        params[:bounds] = bounds_string(options[:bounds])
      end
      "#{protocol}://maps.googleapis.com/maps/api/geocode/json?" + hash_to_query(params)
    end

    def bounds_string(bounds)
      # bounds can be three types:
      # 1. String - we append the string as-is
      # 2. [lat, lng] - a single coordinate
      # 3. [[lat, lng], [lat, lng]] - two coordinates, the SW corner and the NE corner of the bounds
      if bounds.is_a?(Array)
        if bounds.first.is_a?(Array)
          sw, ne = *bounds
        else
          sw = bounds
          ne = bounds
        end
        [sw.join(','), ne.join(',')].join('|')
      else
        bounds.to_s
      end
    end
  end
end

