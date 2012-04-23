module Geocoder::Lookup
  module Route
    module Base
      def routes_between(points, options)
        route_results(points, options).map{ |r| route_result_class.new(r) }
      end
      
      # ----------------------------------------------------------------
      
      ##
      # Geocoder::Result object or nil on timeout or other error.
      #
      def route_results(points, mode)
        fail "not implemented"
      end
      
      # ----------------------------------------------------------------
      
      
      ##
      # Class of the route result objects
      #
      def route_result_class
        Geocoder::Result::Route.const_get(self.class.to_s.split(":").last)
      end
      
      # ----------------------------------------------------------------
      
      
      ##
      # Returns a parsed search result for route (Ruby hash).
      #
      def route_fetch_data(points, options)
        begin
          parse_raw_data route_fetch_raw_data(points, options)
        rescue SocketError => err
          raise_error(err) or warn "Geocoding API connection cannot be established."
        rescue TimeoutError => err
          raise_error(err) or warn "Geocoding API not responding fast enough " +
            "(see Geocoder::Configuration.timeout to set limit)."
        end
      end
      
      # ----------------------------------------------------------------
      
      
      ##
      # Fetches a raw route result (JSON string).
      #
      def route_fetch_raw_data(points, options)
        timeout(Geocoder::Configuration.timeout) do
          url = route_query_url(points, options)
          uri = URI.parse(url)
          unless cache and body = cache[url]
            client = http_client.new(uri.host, uri.port)
            client.use_ssl = true if Geocoder::Configuration.use_https
            response = client.get(uri.request_uri)
            body = response.body
            if cache and (200..399).include?(response.code.to_i)
              cache[url] = body
            end
          end
          body
        end
      end
    end
  end
end