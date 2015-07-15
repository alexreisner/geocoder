module Geocoder
  class FallbackExecutionStrategy
    def initialize(query, options = {})
      @options = options
      @query = query
      @fallback_chain = []

      set_fallback_chain
    end

    def search
      results = nil

      fallback_chain.each do |current_lookup|
        if current_lookup[:skip]
          if current_lookup[:skip].call(query)
            next
          end
        end

        begin
          lookup = create_lookup(current_lookup)
          results = lookup.search(query.text, options)
        rescue => exception
          # no op
        end

        if current_lookup[:failure]
          if current_lookup[:failure].call(results, exception)
            next
          end
        end

        # If we have something raised here then it must have been configured to
        # always_raise so we can re-raise
        raise exception unless exception.nil?

        # We haven't skipped, failed or raised by now so we just
        # return results regardless. We could fall back again but not configured
        # to do so.
        break if results
      end

      results || []
    end

    private

    attr_reader :options, :query, :fallback_chain

    def set_fallback_chain
      if !options[:street_address] and (options[:ip_address] or query.ip_address?)
        configuration = find_ip_lookup_config
      else
        configuration = find_lookup_config
      end

      if configuration.is_a?(Array)
        @fallback_chain = configuration
      else
        @fallback_chain << build_fallback_from_basic(configuration)
      end
    end

    def find_ip_lookup_config
      options[:ip_lookup] || Configuration.ip_lookup || fail_with_config_error('Lookup config not found')
    end

    def find_lookup_config
      options[:lookup] || Configuration.lookup || fail_with_config_error('Lookup config not found')
    end

    def create_lookup(lookup_config)
      Lookup.get(lookup_config[:name])
    end

    def fail_with_config_error(message)
      Geocoder::ConfigurationError.new(message)
    end

    def build_fallback_from_basic(lookup_config)
      { :name => lookup_config }
    end
  end
end
