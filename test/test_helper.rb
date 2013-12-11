require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

class MysqlConnection
  def adapter_name
    "mysql"
  end
end

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

    def self.connection
      MysqlConnection.new
    end

    def method_missing(name, *args, &block)
      if name.to_s[-1..-1] == "="
        write_attribute name.to_s[0...-1], *args
      else
        read_attribute name
      end
    end

    class << self
      def table_name
        'test_table_name'
      end

      def primary_key
        :id
      end
    end

  end
end

# simulate Rails module so Railtie gets loaded
module Rails
end

# Require Geocoder after ActiveRecord simulator.
require 'geocoder'
require "geocoder/lookups/base"

##
# Mock HTTP request to geocoding service.
#
module Geocoder
  module Lookup
    class Base
      private
      def fixture_exists?(filename)
        File.exist?(File.join("test", "fixtures", filename))
      end

      def read_fixture(file)
        filepath = File.join("test", "fixtures", file)
        s = File.read(filepath).strip.gsub(/\n\s*/, "")
        s.instance_eval do
          def body; self; end
          def code; "200"; end
        end
        s
      end

      ##
      # Fixture to use if none match the given query.
      #
      def default_fixture_filename
        "#{fixture_prefix}_madison_square_garden"
      end

      def fixture_prefix
        handle
      end

      def fixture_for_query(query)
        label = query.reverse_geocode? ? "reverse" : query.text.gsub(/[ \.]/, "_")
        filename = "#{fixture_prefix}_#{label}"
        fixture_exists?(filename) ? filename : default_fixture_filename
      end

      def make_api_request(query)
        raise TimeoutError if query.text == "timeout"
        raise SocketError if query.text == "socket_error"
        read_fixture fixture_for_query(query)
      end
    end

    class GooglePremier
      private
      def fixture_prefix
        "google"
      end
    end

    class Dstk
      private
      def fixture_prefix
        "google"
      end
    end

    class Yandex
      private
      def default_fixture_filename
        "yandex_kremlin"
      end
    end

    class Freegeoip
      private
      def default_fixture_filename
        "freegeoip_74_200_247_59"
      end
    end

    class Maxmind
      private
      def default_fixture_filename
        "maxmind_74_200_247_59"
      end
    end

    class Baidu
      private
      def fixture_prefix
        "baidu"
      end
      def default_fixture_filename
        "baidu_shanghai_pearl_tower"
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
end

##
# Geocoded model.
# - Has user-defined primary key (not just 'id')
#
class VenuePlus < Venue

  class << self
    def primary_key
      :custom_primary_key_id
    end
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
end

##
# Geocoded model with block.
#
class Event < ActiveRecord::Base
  geocoded_by :address do |obj,results|
    if result = results.first
      obj.coords_string = "#{result.latitude},#{result.longitude}"
    else
      obj.coords_string = "NOT FOUND"
    end
  end

  def initialize(name, address)
    super()
    write_attribute :name, name
    write_attribute :address, address
  end
end

##
# Reverse geocoded model with block.
#
class Party < ActiveRecord::Base
  reverse_geocoded_by :latitude, :longitude do |obj,results|
    if result = results.first
      obj.country = result.country_code
    end
  end

  def initialize(name, latitude, longitude)
    super()
    write_attribute :name, name
    write_attribute :latitude, latitude
    write_attribute :longitude, longitude
  end
end

##
# Forward and reverse geocoded model.
# Should fill in whatever's missing (coords or address).
#
class GasStation < ActiveRecord::Base
  geocoded_by :address, :latitude => :lat, :longitude => :lon
  reverse_geocoded_by :lat, :lon, :address => :location

  def initialize(name)
    super()
    write_attribute :name, name
  end
end


class Test::Unit::TestCase

  def setup
    Geocoder.configure(:maxmind => {:service => :city_isp_org})
  end

  def teardown
    Geocoder.send(:remove_const, :Configuration)
    load "geocoder/configuration.rb"
  end

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

  def set_api_key!(lookup_name)
    lookup = Geocoder::Lookup.get(lookup_name)
    if lookup.required_api_key_parts.size == 1
      key = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
    elsif lookup.required_api_key_parts.size > 1
      key = lookup.required_api_key_parts
    else
      key = nil
    end
    Geocoder.configure(:api_key => key)
  end
end
