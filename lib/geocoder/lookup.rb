module Geocoder
  module Lookup

    ##
    # Array of valid Lookup service names.
    #
    def self.all_services
      street_services + ip_services
    end

    ##
    # Array of valid Lookup service names, excluding :test.
    #
    def self.all_services_except_test
      all_services - [:test]
    end

    ##
    # All street address lookup services, default first.
    #
    def self.street_services
      [:google, :google_premier, :yahoo, :bing, :geocoder_ca, :yandex, :nominatim, :mapquest, :test]
    end

    ##
    # All IP address lookup services, default first.
    #
    def self.ip_services
      [:freegeoip]
    end

    ##
    # Retrieve a Lookup object from the store.
    # Use this instead of Geocoder::Lookup::X.new to get an
    # already-configured Lookup object.
    #
    def self.get(name)
      @services = {} unless defined?(@services)
      @services[name] = spawn(name) unless @services.include?(name)
      @services[name]
    end


    private # -----------------------------------------------------------------

    ##
    # Spawn a Lookup of the given name.
    #
    def self.spawn(name)
      if all_services.include?(name)
        name = name.to_s
        require "geocoder/lookups/#{name}"
        klass = name.split("_").map{ |i| i[0...1].upcase + i[1..-1] }.join
        Geocoder::Lookup.const_get(klass).new
      else
        valids = all_services.map(&:inspect).join(", ")
        raise ConfigurationError, "Please specify a valid lookup for Geocoder " +
          "(#{name.inspect} is not one of: #{valids})."
      end
    end
  end
end
