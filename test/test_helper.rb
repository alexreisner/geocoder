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
      private #-----------------------------------------------------------------
      def read_fixture(file)
        File.read(File.join("test", "fixtures", file)).strip.gsub(/\n\s*/, "")
      end
    end

    class Google < Base
      private #-----------------------------------------------------------------
      def fetch_raw_data(query)
        raise TimeoutError if query.text == "timeout"
        raise SocketError if query.text == "socket_error"
        file = case query.text
          when "no results";   :no_results
          when "no locality";  :no_locality
          when "no city data"; :no_city_data
          else                 :madison_square_garden
        end
        read_fixture "google_#{file}.json"
      end
    end

    class GooglePremier < Google
    end

    class Yahoo < Base
      private #-----------------------------------------------------------------
      def fetch_raw_data(query)
        raise TimeoutError if query.text == "timeout"
        raise SocketError if query.text == "socket_error"
        file = case query.text
          when "no results v1"; :v1_no_results
          when "madison square garden v1"; :v1_madison_square_garden
          when "no results";    :no_results
          else                  :madison_square_garden
        end
        read_fixture "yahoo_#{file}.json"
      end
    end

    class Yandex < Base
      private #-----------------------------------------------------------------
      def fetch_raw_data(query)
        raise TimeoutError if query.text == "timeout"
        raise SocketError if query.text == "socket_error"
        file = case query.text
          when "no results";  :no_results
          when "invalid key"; :invalid_key
          else                :kremlin
        end
        read_fixture "yandex_#{file}.json"
      end
    end

    class GeocoderCa < Base
      private #-----------------------------------------------------------------
      def fetch_raw_data(query)
        raise TimeoutError if query.text == "timeout"
        raise SocketError if query.text == "socket_error"
        if query.reverse_geocode?
          read_fixture "geocoder_ca_reverse.json"
        else
          file = case query.text
            when "no results";  :no_results
            else                :madison_square_garden
          end
          read_fixture "geocoder_ca_#{file}.json"
        end
      end
    end

    class Freegeoip < Base
      private #-----------------------------------------------------------------
      def fetch_raw_data(query)
        raise TimeoutError if query.text == "timeout"
        raise SocketError if query.text == "socket_error"
        file = case query.text
          when "no results";  :no_results
          else                "74_200_247_59"
        end
        read_fixture "freegeoip_#{file}.json"
      end
    end

    class Bing < Base
      private #-----------------------------------------------------------------
      def fetch_raw_data(query)
        raise TimeoutError if query.text == "timeout"
        raise SocketError if query.text == "socket_error"
        if query.reverse_geocode?
          read_fixture "bing_reverse.json"
        else
          file = case query.text
            when "no results";  :no_results
            else                :madison_square_garden
          end
          read_fixture "bing_#{file}.json"
        end
      end
    end

    class Nominatim < Base
      private #-----------------------------------------------------------------
      def fetch_raw_data(query)
        raise TimeoutError if query.text == "timeout"
        raise SocketError if query.text == "socket_error"
        file = case query.text
          when "no results";  :no_results
          else                :madison_square_garden
        end
        read_fixture "nominatim_#{file}.json"
      end
    end

    class Mapquest < Base
      private #-----------------------------------------------------------------
      def fetch_raw_data(query)
        raise TimeoutError if query.text == "timeout"
        raise SocketError if query.text == "socket_error"
        file = case query.text
          when "no results";  :no_results
          else                :madison_square_garden
        end
        read_fixture "mapquest_#{file}.json"
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

  def is_nan_coordinates?(coordinates)
    return false unless coordinates.respond_to? :size # Should be an array
    return false unless coordinates.size == 2 # Should have dimension 2
    coordinates[0].nan? && coordinates[1].nan? # Both coordinates should be NaN
  end
end

