module Geocoder
  class Query
    attr_accessor :text, :options

    def initialize(text, options = {})
      self.text = text
      self.options = options

      find_execution_strategy
    end

    def execute
      execution_strategy.search
    end

    def to_s
      text
    end

    def sanitized_text
      if coordinates?
        if text.is_a?(Array)
          text.join(',')
        else
          text.split(/\s*,\s*/).join(',')
        end
      else
        text
      end
    end

    ##
    # Is the Query blank? (ie, should we not bother searching?)
    # A query is considered blank if its text is nil or empty string AND
    # no URL parameters are specified.
    #
    def blank?
      !params_given? and (
        (text.is_a?(Array) and text.compact.size < 2) or
        text.to_s.match(/\A\s*\z/)
      )
    end

    ##
    # Does the Query text look like an IP address?
    #
    # Does not check for actual validity, just the appearance of four
    # dot-delimited numbers.
    #
    def ip_address?
      IpAddress.new(text).valid? rescue false
    end

    ##
    # Is the Query text a loopback IP address?
    #
    def loopback_ip_address?
      ip_address? && IpAddress.new(text).loopback?
    end

    ##
    # Does the given string look like latitude/longitude coordinates?
    #
    def coordinates?
      text.is_a?(Array) or (
        text.is_a?(String) and
        !!text.to_s.match(/\A-?[0-9\.]+, *-?[0-9\.]+\z/)
      )
    end

    ##
    # Return the latitude/longitude coordinates specified in the query,
    # or nil if none.
    #
    def coordinates
      sanitized_text.split(',') if coordinates?
    end

    ##
    # Should reverse geocoding be performed for this query?
    #
    def reverse_geocode?
      coordinates?
    end

    def language
      options[:language]
    end

    private # ----------------------------------------------------------------

    attr_reader :execution_strategy

    def find_execution_strategy
      if !options[:street_address] and (options[:ip_address] or ip_address?)
        lookup_config = options[:ip_lookup] || Configuration.ip_lookup
      else
        lookup_config = options[:lookup] || Configuration.lookup
      end

      if lookup_config && lookup_config.is_a?(Array)
        query_strategy_klass = FallbackExecutionStrategy
      else
        query_strategy_klass = SimpleExecutionStrategy
      end

      @execution_strategy = query_strategy_klass.new(self, options)
    end

    def params_given?
      !!(options[:params].is_a?(Hash) and options[:params].keys.size > 0)
    end
  end
end
