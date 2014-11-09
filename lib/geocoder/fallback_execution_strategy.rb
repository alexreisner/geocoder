module Geocoder
  class FallbackExecutionStrategy
    def initialize(query, options = {})
      @options = options
      @query = query
      @fallback_chain = []

      find_fallback_chain
    end

    def search
      results = nil

      #binding.pry

      fallback_chain.each do |current_lookup|
        puts current_lookup[:name]

        if current_lookup[:skip]
          if current_lookup[:skip].call(query)
            puts "skip!!"
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
            puts "fail!"
            next
          end
        end

        # If we have something raised here then it must have been configured to
        # always_raise so we can re-raise
        raise exception unless exception.nil?

        # TODO: We haven't skipped, failed or raised by now so should we just
        # return results regardless? Rather than falling back again, config
        # has not specified this.
        break if results
      end

      results
    end

    private

    attr_reader :options, :query, :fallback_chain

    def find_fallback_chain
      if query.ip_address?
        @fallback_chain = find_ip_lookup_config
      else
        @fallback_chain = find_lookup_config
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
  end
end
