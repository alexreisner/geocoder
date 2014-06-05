module Geocoder
  class FallbackExecutionStrategy
    MAX_RETRY_ATTEMPTS = 2

    def execute(lookup, text, options)
      @lookup = lookup
      error_to_retry_on = configured_fallback_error
      attempts = MAX_RETRY_ATTEMPTS

      begin
        results = @lookup.search(text, options)
      rescue error_to_retry_on => e
        if (attempts -= 1) > 0
          fallback!
          retry
        else
          raise_error(error_to_retry_on, "Fallback limit excceeded on #{@lookup.class.name}.")
        end
      end

      results
    end

    private

    def configured_fallback_error
      if Configuration.fallback_config_valid?
        Configuration.lookup_fallback[:on]
      else
        nil
      end
    end

    def fallback!
      name = Configuration.lookup_fallback[:to]
      @lookup = Lookup.get(name)
    end

    def raise_error(error, message = nil)
      exceptions = Configuration.always_raise
      if exceptions == :all || exceptions.include?( error.is_a?(Class) ? error : error.class )
        raise error, message
      else
        warn(error, message)
      end
    end
  end
end
