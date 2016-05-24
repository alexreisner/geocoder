module Geocoder
  class Batch
    attr_accessor :items, :options

    def initialize(items, options = {})
      self.items = items
      self.options = options
    end

    def execute
      lookup.batch(items, options)
    end

    def to_s
      items.map{|item| item.to_s}
    end

    ##
    # Get a Lookup object (which communicates with the remote geocoding API)
    # appropriate to the Query text.
    #
    def lookup
      if !options[:street_address] and options[:ip_address]
        name = options[:ip_lookup] || Configuration.ip_lookup || Geocoder::Lookup.ip_services.first
      else
        name = options[:lookup] || Configuration.lookup || Geocoder::Lookup.street_services.first
      end
      Lookup.get(name)
    end

    def blank?
      items.length == 0
    end

    def reverse_geocode?
      false
    end
    
  end
end
