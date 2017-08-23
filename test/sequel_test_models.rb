class Place < Sequel::Model(:places)
  plugin :geocoder

  geocoded_by :address

  def initialize(name, address)
    super(name: name, address: address)
  end

end

##
# Geocoded model.
# - Has user-defined primary key (not just 'id')
#
class PlaceWithCustomPrimaryKey < Place
  def primary_key
    :custom_primary_key_id
  end
end


class PlaceReverseGeocoded < Sequel::Model(:places)
  plugin :geocoder

  reverse_geocoded_by :latitude, :longitude

  def initialize(name, latitude, longitude)
    super(name: name, latitude: latitude, longitude: longitude)
  end
end

class PlaceWithCustomResultsHandling < Sequel::Model
  plugin :geocoder

  geocoded_by :address do |obj,results|
    if result = results.first
      obj.coords_string = "#{result.latitude},#{result.longitude}"
    else
      obj.coords_string = "NOT FOUND"
    end
  end

  def initialize(name, address)
    super(name: name, address: address)
  end
end

class PlaceReverseGeocodedWithCustomResultsHandling < Sequel::Model
  plugin :geocoder

  reverse_geocoded_by :latitude, :longitude do |obj,results|
    if result = results.first
      obj.country = result.country_code
    end
  end

  def initialize(name, latitude, longitude)
    super(name: name, latitude: latitude, longitude: longitude)
  end
end

class PlaceWithForwardAndReverseGeocoding < Sequel::Model
  plugin :geocoder

  geocoded_by :address, :latitude => :lat, :longitude => :lon
  reverse_geocoded_by :lat, :lon, :address => :location

  def initialize(name)
    super(name: name)
  end
end

class PlaceWithCustomLookup < Sequel::Model(:places_with_result_class)
  plugin :geocoder

  geocoded_by :address, :lookup => :nominatim do |obj,results|
    if result = results.first
      obj.result_class = result.class
    end
  end

  def initialize(name, address)
    super(name: name, address: address)
  end
end

class PlaceWithCustomLookupProc < Sequel::Model(:places_with_result_class)
  plugin :geocoder

  geocoded_by :address, :lookup => lambda{|obj| obj.custom_lookup } do |obj,results|
    if result = results.first
      obj.result_class = result.class
    end
  end

  def custom_lookup
    :nominatim
  end

  def initialize(name, address)
    super(name: name, address: address)
  end
end

class PlaceReverseGeocodedWithCustomLookup < Sequel::Model(:places_with_result_class)
  plugin :geocoder

  reverse_geocoded_by :latitude, :longitude, :lookup => :nominatim do |obj,results|
    if result = results.first
      obj.result_class = result.class
    end
  end

  def initialize(name, latitude, longitude)
    super(name: name, latitude: latitude, longitude: longitude)
  end
end