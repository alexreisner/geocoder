require "geocoder/configuration"
require "geocoder/calculations"
require "geocoder/cache"
require "geocoder/railtie"
require "geocoder/request"

module Geocoder
  extend self

  ##
  # Search for information about an address or a set of coordinates.
  #
  def search(*args)
    return nil if blank_query?(args[0])
    ip = (args.size == 1 and ip_address?(args.first))
    lookup(ip).search(*args)
  end

  ##
  # Look up the coordinates of the given street or IP address.
  #
  def coordinates(address)
    if result = search(address)
      result.coordinates
    end
  end

  ##
  # Look up the address of the given coordinates.
  #
  def address(latitude, longitude)
    if result = search(latitude, longitude)
      result.address
    end
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
      get_lookup Geocoder::Configuration.lookup || :google
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
    !value.to_s.match(/[A-z0-9]/)
  end
end

Geocoder::Railtie.insert
