class Place < ActiveRecord::Base
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
class PlaceWithCustomPrimaryKey < Place
  class << self
    def primary_key
      :custom_primary_key_id
    end
  end
end

class PlaceReverseGeocoded < ActiveRecord::Base
  reverse_geocoded_by :latitude, :longitude

  def initialize(name, latitude, longitude)
    super()
    write_attribute :name, name
    write_attribute :latitude, latitude
    write_attribute :longitude, longitude
  end
end

class PlaceWithCustomResultsHandling < ActiveRecord::Base
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

class PlaceReverseGeocodedWithCustomResultsHandling < ActiveRecord::Base
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

class PlaceWithForwardAndReverseGeocoding < ActiveRecord::Base
  geocoded_by :address, :latitude => :lat, :longitude => :lon
  reverse_geocoded_by :lat, :lon, :address => :location

  def initialize(name)
    super()
    write_attribute :name, name
  end
end

class PlaceWithCustomLookup < ActiveRecord::Base
  geocoded_by :address, :lookup => :nominatim do |obj,results|
    if result = results.first
      obj.result_class = result.class
    end
  end

  def initialize(name, address)
    super()
    write_attribute :name, name
    write_attribute :address, address
  end
end

class PlaceWithCustomLookupProc < ActiveRecord::Base
  geocoded_by :address, :lookup => lambda{|obj| obj.custom_lookup } do |obj,results|
    if result = results.first
      obj.result_class = result.class
    end
  end

  def custom_lookup
    :nominatim
  end

  def initialize(name, address)
    super()
    write_attribute :name, name
    write_attribute :address, address
  end
end

class PlaceReverseGeocodedWithCustomLookup < ActiveRecord::Base
  reverse_geocoded_by :latitude, :longitude, :lookup => :nominatim do |obj,results|
    if result = results.first
      obj.result_class = result.class
    end
  end

  def initialize(name, latitude, longitude)
    super()
    write_attribute :name, name
    write_attribute :latitude, latitude
    write_attribute :longitude, longitude
  end
end