require 'geocoder/lookups/base'
require 'geocoder/results/amazon_location_service'

module Geocoder::Lookup
  class AmazonLocationService < Base
    def results(query)
      operation, params = operation_and_params(query)

      if cache && (cached = read_cached_results(operation, params))
        @cache_hit = true
        return cached
      end

      resp = client.send(operation, params)
      if cache
        cache[cache_key_for(operation, params)] = serialize_results(resp.results)
      end
      @cache_hit = false
      resp.results
    end

    private

    def operation_and_params(query)
      params = query.options.dup

      # index_name is required
      # Aws::ParamValidator raises ArgumentError on missing required keys
      params.merge!(index_name: configuration[:index_name])

      # Aws::ParamValidator raises ArgumentError on unexpected keys
      params.delete(:lookup)

      # Inherit language from configuration
      params.merge!(language: configuration[:language])

      if query.reverse_geocode?
        [:search_place_index_for_position, params.merge(position: query.coordinates.reverse)]
      else
        [:search_place_index_for_text, params.merge(text: query.text)]
      end
    end

    # The base implementation builds cache keys from the request URL. This
    # lookup uses the AWS SDK rather than HTTP, so build a key from the SDK
    # operation name and its parameters instead.
    def cache_key(query)
      cache_key_for(*operation_and_params(query))
    end

    def cache_key_for(operation, params)
      "#{operation}?#{hash_to_query(params)}"
    end

    def serialize_results(results)
      JSON.generate(results.map(&:to_h))
    end

    def read_cached_results(operation, params)
      body = cache[cache_key_for(operation, params)]
      return nil unless body

      data = JSON.parse(body, symbolize_names: true)
      client.stub_data(operation, results: data).results
    rescue JSON::ParserError, ArgumentError
      # treat unreadable or stale-format cache entries as a miss
      nil
    end

    def client
      return @client if @client
      require_sdk
      keys = configuration.api_key
      if keys
        @client = Aws::LocationService::Client.new(**{
          region: keys[:region],
          access_key_id: keys[:access_key_id],
          secret_access_key: keys[:secret_access_key]
        }.compact)
      else
        @client = Aws::LocationService::Client.new
      end
    end

    def require_sdk
      begin
        require 'aws-sdk-locationservice'
      rescue LoadError
        raise_error(Geocoder::ConfigurationError) ||
          Geocoder.log(
            :error,
            "Couldn't load the Amazon Location Service SDK. " +
            "Install it with: gem install aws-sdk-locationservice -v '~> 1.4'"
          )
      end
    end
  end
end
