require "geocoder/configuration"
require "geocoder/calculations"
require "geocoder/cache"
require "geocoder/request"
require "geocoder/models/active_record"
require "geocoder/models/mongoid"
require "geocoder/models/mongo_mapper"

module Geocoder
  extend self

  ##
  # Search for information about an address or a set of coordinates.
  #
  def search(query)
    blank_query?(query) ? [] : lookup(query).search(query)
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
  # Look up the address of the given coordinates ([lat,lon])
  # or IP address (string).
  #
  def address(query)
    if (results = search(query)).size > 0
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

  ##
  # Array of valid Lookup names.
  #
  def valid_lookups
    street_lookups + ip_lookups
  end

  ##
  # All street address lookups, default first.
  #
  def street_lookups
    [:google, :google_premier, :yahoo, :bing, :geocoder_ca, :yandex]
  end

  ##
  # All IP address lookups, default first.
  #
  def ip_lookups
    [:freegeoip]
  end


  # exception classes
  class Error < StandardError; end
  class ConfigurationError < Error; end


  private # -----------------------------------------------------------------

  ##
  # Get a Lookup object (which communicates with the remote geocoding API).
  # Takes a search query and returns an IP or street address Lookup
  # depending on the query contents.
  #
  def lookup(query)
    if ip_address?(query)
      get_lookup(ip_lookups.first)
    else
      get_lookup(Configuration.lookup || street_lookups.first)
    end
  end

  ##
  # Retrieve a Lookup object from the store.
  #
  def get_lookup(name)
    @lookups = {} unless defined?(@lookups)
    @lookups[name] = spawn_lookup(name) unless @lookups.include?(name)
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
      Geocoder::Lookup.const_get(klass).new
    else
      valids = valid_lookups.map(&:inspect).join(", ")
      raise ConfigurationError, "Please specify a valid lookup for Geocoder " +
        "(#{name.inspect} is not one of: #{valids})."
    end
  end

  ##
  # Does the given value look like an IP address?
  #
  # Does not check for actual validity, just the appearance of four
  # dot-delimited numbers.
  #
  def ip_address?(value)
    !!value.to_s.match(/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/)
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
