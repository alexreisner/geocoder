require "geocoder/configuration"
require "geocoder/calculations"
require "geocoder/active_record"
require "geocoder/railtie"

module Geocoder
  extend self

  ##
  # Alias for Geocoder.lookup.search.
  #
  def search(*args)
    lookup.search(*args)
  end

  ##
  # Look up the coordinates of the given street address.
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


  # exception classes
  class Error < StandardError; end
  class ConfigurationError < Error; end


  private # -----------------------------------------------------------------

  ##
  # Get the lookup object (which communicates with the remote geocoding API).
  #
  def lookup
    unless defined?(@lookup)
      set_lookup Geocoder::Configuration.lookup
    end
    @lookup
  end

  def set_lookup(value)
    if value == :yahoo
      require "geocoder/lookups/yahoo"
      @lookup = Geocoder::Lookup::Yahoo.new
    else
      require "geocoder/lookups/google"
      @lookup = Geocoder::Lookup::Google.new
    end
  end
end

Geocoder::Railtie.insert
