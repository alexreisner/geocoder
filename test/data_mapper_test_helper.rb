require 'rubygems'
require 'test/unit'
require 'test_helper'
require 'data_mapper'
require 'geocoder/models/data_mapper'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

DataMapper::Logger.new($stdout, :debug)

##
# Geocoded model.
#
class PlaceUsingDataMapper
  include Geocoder::Model::DataMapper
  include DataMapper::Resource

  property :name,       String
  property :address,    String
  property :latitude,   Decimal
  property :longitude,  Decimal

  geocoded_by :address

  def coordinates
    [latitude, longitude]
  end

  def initialize(name, address)
    super()
    attribute_set :name, name
    attribute_set :address, address
  end
end
