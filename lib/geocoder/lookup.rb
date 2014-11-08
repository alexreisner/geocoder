module Geocoder
  module Lookup
    extend self

    ##
    # Array of valid Lookup service names.
    #
    def all_services
      street_services + ip_services
    end

    ##
    # Array of valid Lookup service names, excluding :test.
    #
    def all_services_except_test
      all_services - [:test]
    end

    ##
    # All street address lookup services, default first.
    #
    def street_services
      [
        :dstk,
        :esri,
        :google,
        :google_premier,
        :google_places_details,
        :yahoo,
        :bing,
        :geocoder_ca,
        :geocoder_us,
        :yandex,
        :nominatim,
        :mapquest,
        :opencagedata,
        :ovi,
        :here,
        :baidu,
        :geocodio,
        :smarty_streets,
        :okf,
        :postcode_anywhere_uk,
        :test
      ]
    end

    ##
    # All IP address lookup services, default first.
    #
    def ip_services
      [
        :baidu_ip,
        :freegeoip,
        :geoip2,
        :maxmind,
        :maxmind_local,
        :telize,
        :pointpin
      ]
    end

    ##
    # Retrieve a Lookup object from the store.
    # Use this instead of Geocoder::Lookup::X.new to get an
    # already-configured Lookup object.
    #
    def get(name)
      @services = {} unless defined?(@services)
      @services[name] = spawn(name) unless @services.include?(name)
      @services[name]
    end


    private # -----------------------------------------------------------------

    ##
    # Spawn a Lookup of the given name.
    #
    def spawn(name)
      if all_services.include?(name)
        Geocoder::Lookup.const_get(classify_name(name)).new
      else
        valids = all_services.map(&:inspect).join(", ")
        raise ConfigurationError, "Please specify a valid lookup for Geocoder " +
          "(#{name.inspect} is not one of: #{valids})."
      end
    end

    ##
    # Convert an "underscore" version of a name into a "class" version.
    #
    def classify_name(filename)
      filename.to_s.split("_").map{ |i| i[0...1].upcase + i[1..-1] }.join
    end
  end
end

Geocoder::Lookup.all_services.each do |name|
  require "geocoder/lookups/#{name}"
end
