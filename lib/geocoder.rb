require "geocoder/configuration"
require "geocoder/calculations"
require "geocoder/lookup"
require "geocoder/result"
require "geocoder/active_record"
require "geocoder/railtie"

module Geocoder
  extend self

  ##
  # Alias for Geocoder::Lookup.search.
  #
  def search(*args)
    Lookup.search(*args)
  end

  # exception classes
  class Error < StandardError; end
  class ConfigurationError < Error; end
end

Geocoder::Railtie.insert
