require "geocoder/configuration"
require "geocoder/calculations"
require "geocoder/result"
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

  # exception classes
  class Error < StandardError; end
  class ConfigurationError < Error; end
end

Geocoder::Railtie.insert
