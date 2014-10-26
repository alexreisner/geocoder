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
        @fallback_chain = options[:ip_lookup] || Configuration.ip_lookup || fail
      else
        @fallback_chain = options[:lookup] || Configuration.lookup || fail
      end
    end

    def create_lookup(lookup)
      Lookup.get(lookup[:name])
    end
  end
end
