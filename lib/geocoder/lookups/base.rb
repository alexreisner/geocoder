require 'net/http'
require 'active_support/json'

module Geocoder
  module Lookup
    class Base

      ##
      # Takes a search string (eg: "Mississippi Coast Coliseumf, Biloxi, MS")
      # for geocoding, or coordinates (latitude, longitude) for reverse
      # geocoding. Returns an array of Geocoder::Result objects,
      # or nil if not found or if network error.
      #
      def search(*args)
        return [] if args[0].nil? || args[0] == ""
        if res = results(args.join(","), args.size == 2)
          res.map{ |r| result_class.new(r) }
        end
      end


      private # -------------------------------------------------------------

      ##
      # Array of results, or nil on timeout or other error.
      #
      def results(query, reverse = false)
        fail
      end

      ##
      # URL to use for querying the geocoding engine.
      #
      def query_url(query, reverse = false)
        fail
      end

      ##
      # Class of the result objects
      #
      def result_class
        eval("Geocoder::Result::#{self.class.to_s.split(":").last}")
      end

      ##
      # Returns a parsed search result (Ruby hash).
      #
      def fetch_data(query, reverse = false)
        begin
          ActiveSupport::JSON.decode(fetch_raw_data(query, reverse))
        rescue SocketError
          warn "Geocoding API connection cannot be established."
        rescue TimeoutError
          warn "Geocoding API not responding fast enough " +
            "(see Geocoder::Configuration.timeout to set limit)."
        end
      end

      ##
      # Fetches a raw search result (JSON string).
      #
      def fetch_raw_data(query, reverse = false)
        return nil if query.blank?
        url = query_url(query, reverse)
        timeout(Geocoder::Configuration.timeout) do
          Net::HTTP.get_response(URI.parse(url)).body
        end
      end
    end
  end
end
