require 'net/http'
unless defined?(ActiveSupport::JSON)
  begin
    require 'json'
  rescue LoadError
    raise LoadError, "Please install the 'json' or 'json_pure' gem to parse geocoder results."
  end
end

module Geocoder
  module Lookup
    class Base

      ##
      # Query the geocoding API and return a Geocoder::Result object.
      # Returns +nil+ on timeout or error.
      #
      # Takes a search string (eg: "Mississippi Coast Coliseumf, Biloxi, MS",
      # "205.128.54.202") for geocoding, or coordinates (latitude, longitude)
      # for reverse geocoding.
      #
      def search(*args)
        if res = result(args.join(","), args.size == 2)
          result_class.new(res)
        end
      end


      private # -------------------------------------------------------------

      ##
      # Geocoder::Result object or nil on timeout or other error.
      #
      def result(query, reverse = false)
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
        if defined?(ActiveSupport::JSON)
          ActiveSupport::JSON.decode(raw_data)
        else
          begin
            JSON.parse(raw_data)
          rescue
            warn "Geocoding API's response was not valid JSON."
          end
        end
      end

      ##
      # Fetches a raw search result (JSON string).
      #
      def fetch_raw_data(query, reverse = false)
        url = query_url(query, reverse)
        timeout(Geocoder::Configuration.timeout) do
          Net::HTTP.get_response(URI.parse(url)).body
        end
      end

      ##
      # Is the given string a loopback IP address?
      #
      def loopback_address?(ip)
        !!(ip == "0.0.0.0" or ip.match(/^127/))
      end

      ##
      # Simulate ActiveSupport's Object#to_query.
      #
      def hash_to_query(hash)
        require 'cgi' unless defined?(CGI) && defined?(CGI.escape)
        hash.collect{ |p| p.map{ |i| CGI.escape i.to_s } * '=' }.sort * '&'
      end
    end
  end
end
