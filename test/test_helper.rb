require 'rubygems'
require 'test/unit'
require 'active_support/core_ext'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

##
# Simulate enough of ActiveRecord::Base that objects can be used for testing.
#
module ActiveRecord
  class Base

    def initialize
      @attributes = {}
    end

    def read_attribute(attr_name)
      @attributes[attr_name.to_sym]
    end

    def write_attribute(attr_name, value)
      @attributes[attr_name.to_sym] = value
    end

    def update_attribute(attr_name, value)
      write_attribute(attr_name.to_sym, value)
    end

    def self.scope(*args); end
  end
end

# Require Geocoder after ActiveRecord simulator.
require 'geocoder'
require "geocoder/lookups/base"

##
# Mock HTTP request to geocoding service.
#
module Geocoder
  module Lookup
    class Google < Base
      private #-----------------------------------------------------------------
      def fetch_raw_data(query, reverse = false)
        File.read(File.join("test", "fixtures", "google_madison_square_garden.json"))
      end
    end

    class Yahoo < Base
      private #-----------------------------------------------------------------
      def fetch_raw_data(query, reverse = false)
        File.read(File.join("test", "fixtures", "yahoo_madison_square_garden.json"))
      end
    end

    class Freegeoip < Base
      private #-----------------------------------------------------------------
      def fetch_raw_data(query, reverse = false)
        File.read(File.join("test", "fixtures", "freegeoip_74_200_247_59.json"))
      end
    end
  end
end

##
# Geocoded model.
#
class Venue < ActiveRecord::Base
  geocoded_by :address

  def initialize(name, address)
    super()
    write_attribute :name, name
    write_attribute :address, address
  end

  ##
  # If method not found, assume it's an ActiveRecord attribute reader.
  #
  def method_missing(name, *args, &block)
    @attributes[name]
  end
end

##
# Reverse geocoded model.
#
class Landmark < ActiveRecord::Base
  reverse_geocoded_by :latitude, :longitude

  def initialize(name, latitude, longitude)
    super()
    write_attribute :name, name
    write_attribute :latitude, latitude
    write_attribute :longitude, longitude
  end

  ##
  # If method not found, assume it's an ActiveRecord attribute reader.
  #
  def method_missing(name, *args, &block)
    @attributes[name]
  end
end

class Test::Unit::TestCase
  def venue_params(abbrev)
    {
      :msg => ["Madison Square Garden", "4 Penn Plaza, New York, NY"]
    }[abbrev]
  end

  def landmark_params(abbrev)
    {
      :msg => ["Madison Square Garden", 40.750354, -73.993371]
    }[abbrev]
  end
end
