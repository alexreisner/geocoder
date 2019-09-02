require 'geocoder/lookups/base'
require "geocoder/results/map_kit"
require 'uri'
require 'net/http'

module Geocoder::Lookup
    class MapKit < Base
        class Token
            def self.token(configuration)
                headers = {
                    'alg' => ALGORITHM,
                    'kid' => configuration.api_key[:mapkit_key_id],
                    'typ' => 'JWT'
                }

                payload = {
                    'iss' => configuration.api_key[:mapkit_team_id],
                    'iat' => Time.now.to_i,
                    'exp' => 1.day.from_now.to_i
                }

                JWT.encode(payload, private_key(configuration), ALGORITHM, headers)
            end

            private

            ALGORITHM = "ES256"

            def self.private_key(configuration)
                OpenSSL::PKey::EC.new(configuration.api_key[:mapkit_private_key])
            end
        end

        def name
            "MapKit"
        end


        def supported_protocols
            [:https]
        end

        def required_api_key_parts
            ["mapkit_key_id", "mapkit_team_id", "mapkit_private_key"]
        end


        ##
        # Geocoder::Result object or nil on timeout or other error.
        #
        def results(query)
            return [] unless doc = fetch_data(query)
            doc
        end

        ##
        # String which, when concatenated with url_query_string(query)
        # produces the full query URL. Should include the "?" a the end.
        #
        def base_query_url(query)
            "#{protocol}://api.apple-mapkit.com/v1/geocode?"
        end

        def query_url_params(query)
            params = {
                q: query.text
            }

            params
        end

        private
        # Overwrite implementation in Geocoder::Lookup::Base in order to implement a complex token handling
        def make_api_request(query)
            response = make_request(query_url(query), access_token)

            raise_error(Geocoder::InvalidApiKey, "unable to request access token from api") if response.nil? || !response.is_a?(Net::HTTPSuccess)

            response
        rescue Timeout::Error
            raise Geocoder::LookupTimeout
        rescue Errno::EHOSTUNREACH, Errno::ETIMEDOUT, Errno::ENETUNREACH, Errno::ECONNRESET
            raise Geocoder::NetworkError
        end

        def make_request(uri_string, token)
            response = nil
            uri = URI.parse(uri_string)
            http_client.start(uri.host, uri.port, use_ssl: use_ssl?, open_timeout: configuration.timeout, read_timeout: configuration.timeout) do |client|
                configure_ssl!(client) if use_ssl?
                req = Net::HTTP::Get.new(uri.request_uri, configuration.http_headers)

                req["Authorization"] = "Bearer #{token}"
                req["Accept"] = '*/*'
                req["Cache-Control"] = 'no-cache'
                req["Accept-Encoding"] = 'deflate'
                req["cache-control"] = 'no-cache'

                response = client.request(req)
            end

            response
        end

        def access_token
            expired_at_string   = cache["mapKit_key_expired"]
            token               = cache["mapKit_token"]

            if expired_at_string.nil? || (Time.parse(expired_at_string) < (Time.now + 5.seconds))
                response = make_request("https://cdn.apple-mapkit.com/ma/bootstrap?apiVersion=2&mkjsVersion=5.28.1&poi=1", Token::token(configuration))

                raise_error(Geocoder::InvalidApiKey, "unable to request access token from api") if response.nil? || !response.is_a?(Net::HTTPSuccess)

                response_hash = JSON.parse(response.read_body)

                expires_in = response_hash["authInfo"]["expires_in"]
                token = response_hash["authInfo"]["access_token"]
                cache["mapKit_token"]       = token
                cache["mapKit_key_expired"] = (Time.now + expires_in).to_s
            end

            token
        end
    end
end