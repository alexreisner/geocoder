require 'net/http'
require 'net/https'
require 'uri'

unless defined?(ActiveSupport::JSON)
  begin
    require 'rubygems' # for Ruby 1.8
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
      # for reverse geocoding. Returns an array of <tt>Geocoder::Result</tt>s.
      #
      def search(query, options = {})
        query = Geocoder::Query.new(query, options) unless query.is_a?(Geocoder::Query)
        results(query).map{ |r|
          result = result_class.new(r)
          result.cache_hit = @cache_hit if cache
          result
        }
      end

      ##
      # Return the URL for a map of the given coordinates.
      #
      # Not necessarily implemented by all subclasses as only some lookups
      # also provide maps.
      #
      def map_link_url(coordinates)
        nil
      end


      private # -------------------------------------------------------------

      ##
      # Object used to make HTTP requests.
      #
      def http_client
        protocol = "http#{'s' if Geocoder::Configuration.use_https}"
        proxy_name = "#{protocol}_proxy"
        if proxy = Geocoder::Configuration.send(proxy_name)
          proxy_url = protocol + '://' + proxy
          begin
            uri = URI.parse(proxy_url)
          rescue URI::InvalidURIError
            raise ConfigurationError,
              "Error parsing #{protocol.upcase} proxy URL: '#{proxy_url}'"
          end
          Net::HTTP::Proxy(uri.host, uri.port, uri.user, uri.password)
        else
          Net::HTTP
        end
      end

      ##
      # Geocoder::Result object or nil on timeout or other error.
      #
      def results(query)
        fail
      end

      def query_url_params(query)
        query.options[:params] || {}
      end

      def url_query_string(query)
        hash_to_query(
          query_url_params(query).reject{ |key,value| value.nil? }
        )
      end

      ##
      # URL to use for querying the geocoding engine.
      #
      def query_url(query)
        fail
      end

      ##
      # Class of the result objects
      #
      def result_class
        Geocoder::Result.const_get(self.class.to_s.split(":").last)
      end

      ##
      # Raise exception if configuration specifies it should be raised.
      # Return false if exception not raised.
      #
      def raise_error(error, message = nil)
        exceptions = Geocoder::Configuration.always_raise
        if exceptions == :all or exceptions.include?( error.is_a?(Class) ? error : error.class )
          raise error, message
        else
          false
        end
      end

      ##
      # Returns a parsed search result (Ruby hash).
      #
      def fetch_data(query)
        parse_raw_data fetch_raw_data(query)
      rescue SocketError => err
        raise_error(err) or warn "Geocoding API connection cannot be established."
      rescue TimeoutError => err
        raise_error(err) or warn "Geocoding API not responding fast enough " +
          "(see Geocoder::Configuration.timeout to set limit)."
      end

      ##
      # Parses a raw search result (returns hash or array).
      #
      def parse_raw_data(raw_data)
        if defined?(ActiveSupport::JSON)
          ActiveSupport::JSON.decode(raw_data)
        else
          JSON.parse(raw_data)
        end
      rescue
        warn "Geocoding API's response was not valid JSON."
      end

      ##
      # Protocol to use for communication with geocoding services.
      # Set in configuration but not available for every service.
      #
      def protocol
        "http" + (Geocoder::Configuration.use_https ? "s" : "")
      end

      ##
      # Fetches a raw search result (JSON string).
      #
      def fetch_raw_data(query)
        timeout(Geocoder::Configuration.timeout) do
          url = query_url(query)
          uri = URI.parse(url)
          if cache and body = cache[url]
            @cache_hit = true
          else
            client = http_client.new(uri.host, uri.port)
            client.use_ssl = true if Geocoder::Configuration.use_https
            response = client.get(uri.request_uri, Geocoder::Configuration.http_headers)
            body = response.body
            if cache and (200..399).include?(response.code.to_i)
              cache[url] = body
            end
            @cache_hit = false
          end
          body
        end
      end

      ##
      # The working Cache object.
      #
      def cache
        Geocoder.cache
      end

      ##
      # Simulate ActiveSupport's Object#to_query.
      # Removes any keys with nil value.
      #
      def hash_to_query(hash)
        require 'cgi' unless defined?(CGI) && defined?(CGI.escape)
        hash.collect{ |p|
          p[1].nil? ? nil : p.map{ |i| CGI.escape i.to_s } * '='
        }.compact.sort * '&'
      end
    end
  end
end
