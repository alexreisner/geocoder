module Geocoder
  class SimpleExecutionStrategy
    def initialize(query, options = {})
      @options = options
      @query = query
    end

    def search
      lookup.search(query.text)
    end

    private

    attr_reader :options, :query

    def lookup
      if query.ip_address?
        lookup_name = options[:ip_lookup] || Configuration.ip_lookup || Geocoder::Lookup.ip_services.first
      else
        lookup_name = options[:lookup] || Configuration.lookup || Geocoder::Lookup.street_services.first
      end

      Lookup.get(lookup_name)
    end
  end
end
