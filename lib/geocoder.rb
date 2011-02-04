require "geocoder/calculations"
require "geocoder/lookup"
require "geocoder/result"
require "geocoder/active_record"

module Geocoder
  extend self

  ##
  # Takes a search string (eg: "Mississippi Coast Coliseumf, Biloxi, MS") for
  # geocoding, or coordinates (latitude, longitude) for reverse geocoding.
  # Returns a Geocoder::Result object.
  #
  def search(*args)
    if args.size == 2
      Lookup.search(args[0], args[1], true)
    else
      Lookup.search(args[0], false)
    end
  end
end


##
# Add geocoded_by method to ActiveRecord::Base so Geocoder is accessible.
#
ActiveRecord::Base.class_eval do

  ##
  # Set attribute names and include the Geocoder module.
  #
  def self.geocoded_by(address_attr, options = {})
    _geocoder_init(
      :user_address => address_attr,
      :latitude  => options[:latitude]  || :latitude,
      :longitude => options[:longitude] || :longitude
    )
  end

  ##
  # Set attribute names and include the Geocoder module.
  #
  def self.reverse_geocoded_by(latitude_attr, longitude_attr, options = {})
    _geocoder_init(
      :fetched_address => options[:address] || :address,
      :latitude  => latitude_attr,
      :longitude => longitude_attr
    )
  end

  def self._geocoder_init(options)
    unless _geocoder_initialized?
      class_inheritable_reader :geocoder_options
      class_inheritable_hash_writer :geocoder_options
    end
    self.geocoder_options = options
    unless _geocoder_initialized?
      include Geocoder::ActiveRecord
    end
  end

  def self._geocoder_initialized?
    included_modules.include? Geocoder::ActiveRecord
  end
end


class GeocoderError < StandardError
end

class GeocoderConfigurationError < GeocoderError
end
