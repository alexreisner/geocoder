require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

Mongoid.configure do |config|
  config.logger = Logger.new($stderr, :debug)
end

##
# Geocoded model.
#
class Place
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
