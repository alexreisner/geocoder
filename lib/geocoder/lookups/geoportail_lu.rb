require 'geocoder/lookups/base'
require "geocoder/results/geoportail_lu"

module Geocoder
  module Lookup
    class GeoportailLu < Base

      def name
        "Geoportail.lu"
      end

      def query_url(query)
        url_base_path(query) + url_query_string(query)
      end

      private

      def url_base_path(query)
        query.reverse_geocode? ? reverse_geocode_url_base_path : search_url_base_path
      end

      def search_url_base_path
        "#{protocol}://api.geoportail.lu/geocoder/search?"
      end

      def reverse_geocode_url_base_path
        "#{protocol}://api.geoportail.lu/geocoder/reverseGeocode?"
      end

      def query_url_geoportail_lu_params(query)
        query.reverse_geocode? ? reverse_geocode_params(query) : search_params(query)
      end

      def search_params(query)
        {
            queryString: query.sanitized_text
        }
      end

      def reverse_geocode_params(query)
        lat_lon = query.coordinates
        {
            lat: lat_lon.first,
            lon: lat_lon.last
        }
      end

      def query_url_params(query)
        query_url_geoportail_lu_params(query).merge(super)
      end

      def results(query)
        return [] unless doc = fetch_data(query)
        if doc['success'] == true
          result = doc['results']
        else
          result = []
          raise_error(Geocoder::Error) ||
              warn("Geportail.lu Geocoding API error")
        end
        result
      end
    end
  end
end
