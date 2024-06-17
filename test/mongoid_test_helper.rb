require 'rubygems'
require 'test/unit'
require 'test_helper'
require 'mongoid'
require 'geocoder/models/mongoid'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

if (::Mongoid::VERSION >= "3")
  Mongoid.logger = Logger.new($stderr, :debug)
else
  Mongoid.configure do |config|
    config.logger = Logger.new($stderr, :debug)
  end
end

##
# Geocoded model.
#
class PlaceUsingMongoid
  include Mongoid::Document
  include Geocoder::Model::Mongoid

  geocoded_by :address, :coordinates => :location
  field :name
  field :address
  field :location, :type => Array

  def initialize(name, address)
    super()
    write_attribute :name, name
    write_attribute :address, address
  end
end

class PlaceUsingMongoidWithoutIndex
  include Mongoid::Document
  include Geocoder::Model::Mongoid

  field :location, :type => Array
  geocoded_by :location, :skip_index => true
end

class PlaceUsingMongoidReverseGeocoded
  include Mongoid::Document
  include Geocoder::Model::Mongoid

  field :address
  field :coordinates, :type => Array
  reverse_geocoded_by :coordinates

  def initialize(name, latitude, longitude)
    super()
    write_attribute :name, name
    write_attribute :coordinates, [latitude, longitude]
  end
end

class PlaceUsingMongoidWithCustomResultsHandling
  include Mongoid::Document
  include Geocoder::Model::Mongoid

  field :location, :type => Array
  field :coords_string
  field :name
  field :address
  geocoded_by :address, :coordinates => :location do |obj,results|
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

class PlaceUsingMongoidReverseGeocodedWithCustomResultsHandling
  include Mongoid::Document
  include Geocoder::Model::Mongoid

  field :name
  field :country
  field :coordinates, :type => Array

  reverse_geocoded_by :coordinates do |obj,results|
    if result = results.first
      obj.country = result.country_code
    end
  end

  def initialize(name, latitude, longitude)
    super()
    write_attribute :name, name
    write_attribute :coordinates, [latitude, longitude]
  end
end
