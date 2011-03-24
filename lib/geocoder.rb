require "geocoder/configuration"
require "geocoder/calculations"
require "geocoder/cache"
require "geocoder/request"

module Geocoder
  extend self

  ##
  # Search for information about an address or a set of coordinates.
  #
  def search(*args)
    if blank_query?(args[0])
      results = []
    else
      ip = (args.size == 1 and ip_address?(args.first))
      results = lookup(ip).search(*args)
    end
    results.instance_eval do
      def warn_search_deprecation(attr)
        warn "DEPRECATION WARNING: Geocoder.search now returns an array of Geocoder::Result objects. " +
          "Calling '%s' directly on the returned array will cause an exception in Geocoder v1.0." % attr
      end

      def coordinates; warn_search_deprecation('coordinates'); first.coordinates if first; end
      def latitude; warn_search_deprecation('latitude'); first.latitude if first; end
      def longitude; warn_search_deprecation('longitude'); first.longitude if first; end
      def address; warn_search_deprecation('address'); first.address if first; end
      def city; warn_search_deprecation('city'); first.city if first; end
      def country; warn_search_deprecation('country'); first.country if first; end
      def country_code; warn_search_deprecation('country_code'); first.country_code if first; end
    end
    return results
  end

  ##
  # Look up the coordinates of the given street or IP address.
  #
  def coordinates(address)
    if (results = search(address)).size > 0
      results.first.coordinates
    end
  end

  ##
  # Look up the address of the given coordinates.
  #
  def address(latitude, longitude)
    if (results = search(latitude, longitude)).size > 0
      results.first.address
    end
  end

  ##
  # The working Cache object, or +nil+ if none configured.
  #
  def cache
    if @cache.nil? and store = Configuration.cache
      @cache = Cache.new(store, Configuration.cache_prefix)
    end
    @cache
  end


  # exception classes
  class Error < StandardError; end
  class ConfigurationError < Error; end


  private # -----------------------------------------------------------------

  ##
  # Get a Lookup object (which communicates with the remote geocoding API).
  # Returns an IP address lookup if +ip+ parameter true.
  #
  def lookup(ip = false)
    if ip
      get_lookup :freegeoip
    else
      get_lookup Configuration.lookup || :google
    end
  end

  ##
  # Retrieve a Lookup object from the store.
  #
  def get_lookup(name)
    unless defined?(@lookups)
      @lookups = {}
    end
    unless @lookups.include?(name)
      @lookups[name] = spawn_lookup(name)
    end
    @lookups[name]
  end

  ##
  # Spawn a Lookup of the given name.
  #
  def spawn_lookup(name)
    if valid_lookups.include?(name)
      name = name.to_s
      require "geocoder/lookups/#{name}"
      klass = name.split("_").map{ |i| i[0...1].upcase + i[1..-1] }.join
      eval("Geocoder::Lookup::#{klass}.new")
    else
      valids = valid_lookups.map{ |l| ":#{l}" }.join(", ")
      raise ConfigurationError, "Please specify a valid lookup for Geocoder " +
        "(#{name.inspect} is not one of: #{valids})."
    end
  end

  ##
  # Array of valid Lookup names.
  #
  def valid_lookups
    [:google, :yahoo, :geocoder_ca, :freegeoip]
  end

  ##
  # Does the given value look like an IP address?
  #
  # Does not check for actual validity, just the appearance of four
  # dot-delimited 8-bit numbers.
  #
  def ip_address?(value)
    !!value.match(/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/)
  end

  ##
  # Is the given search query blank? (ie, should we not bother searching?)
  #
  def blank_query?(value)
    !!value.to_s.match(/^\s*$/)
  end
end

# load Railtie if Rails exists
if defined?(Rails)
  require "geocoder/railtie"
  Geocoder::Railtie.insert
end
