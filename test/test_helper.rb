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

##
# Mock HTTP request to Google.
#
module Geocoder
  def self._fetch_raw_response(query)
    File.read(File.join("test", "fixtures", "madison_square_garden.json"))
  end
end

##
# Geocoded model.
#
class Venue < ActiveRecord::Base
  geocoded_by :address

  def initialize(name, query)
    super()
    write_attribute :name, name
    write_attribute :query, query
    
    if query.kind_of?(Array)
      write_attribute :latitude, query.first
      write_attribute :longitude, query.last
    else    
      write_attribute :address, query
    end
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
      :msg => ["Madison Square Garden", "4 Penn Plaza, New York, NY"],
      :coordinates => ["Madison Square Garden", [40.7503540, -73.9933710]]
    }[abbrev]
  end
end
