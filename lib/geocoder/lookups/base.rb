require 'net/http'
unless defined? ActiveSupport::JSON
  begin
    require 'json'
  rescue LoadError
    raise LoadError, "Please install the json gem to parse geocoder results."
  end
end

module Geocoder
  module Lookup
    class Base

      ##
      # An array of Geocoder::Result objects.
      #
      # Takes a search string (eg: "Mississippi Coast Coliseumf, Biloxi, MS",
      # "205.128.54.202") for geocoding, or coordinates (latitude, longitude)
      # for reverse geocoding.
      #
      def search(*args)
        if res = results(args.join(","), args.size == 2)
          res.map{ |r| result_class.new(r) }
        else
          []
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
          parse_raw_data fetch_raw_data(query, reverse)
        rescue SocketError
          warn "Geocoding API connection cannot be established."
        rescue TimeoutError
          warn "Geocoding API not responding fast enough " +
            "(see Geocoder::Configuration.timeout to set limit)."
        end
      end

      ##
      # Parses a raw search result (returns hash or array).
      #
      def parse_raw_data(raw_data)
        if defined?(JSON)
          begin
            JSON.parse(raw_data)
          rescue JSON::ParseError
            warn "Geocoding API's response was not valid JSON."
          end
        elsif defined?(ActiveSupport::JSON)
          ActiveSupport::JSON.decode(raw_data)
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
