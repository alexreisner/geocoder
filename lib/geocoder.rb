##
# Add geocoding functionality (via Google) to any object.
#
module Geocoder
  
  ##
  # Implementation of 'included' hook method.
  #
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do

      # named scope: geocoded objects
	    named_scope :geocoded,
	      :conditions => "latitude IS NOT NULL AND longitude IS NOT NULL"

      # named scope: not-geocoded objects
	    named_scope :not_geocoded,
	      :conditions => "latitude IS NULL OR longitude IS NULL"
	  end
  end
    
  ##
  # Methods which will be class methods of the including class.
  #
  module ClassMethods

    ##
    # Find all objects within a radius (in miles) of the given location
    # (address string). Location (the first argument) may be either a string
    # to geocode or an array of coordinates (<tt>[lat,long]</tt>).
    #
    def find_near(location, radius = 20, options = {})
      latitude, longitude = location.is_a?(Array) ?
        location : Geocoder.fetch_coordinates(location)
      return [] unless (latitude and longitude)
      all(find_near_options(latitude, longitude, radius, options))
    end
    
    ##
    # Get options hash suitable for passing to ActiveRecord.find to get
    # records within a radius (in miles) of the given point.
    # Taken from excellent tutorial at:
    # http://www.scribd.com/doc/2569355/Geo-Distance-Search-with-MySQL
    # 
    # Options hash may include:
    # 
    # +order+     :: column(s) for ORDER BY SQL clause
    # +limit+     :: number of records to return (for LIMIT SQL clause)
    # +offset+    :: number of records to skip (for LIMIT SQL clause)
    #
    def find_near_options(latitude, longitude, radius = 20, options = {})

      # Set defaults/clean up arguments.
      options[:order] ||= 'distance ASC'
      radius            = radius.to_i

      # Constrain search to a (radius x radius) square.
      factor = (Math::cos(latitude * Math::PI / 180.0) * 69.0).abs
      lon_lo = longitude - (radius / factor);
      lon_hi = longitude + (radius / factor);
      lat_lo = latitude  - (radius / 69.0);
      lat_hi = latitude  + (radius / 69.0);

      # Build limit clause.
      limit = nil
      if options[:limit] or options[:offset]
        options[:offset] ||= 0
        limit = "#{options[:offset]},#{options[:limit]}"
      end

      # Generate hash.
      {
        :select => "*, 3956 * 2 * ASIN(SQRT(" +
          "POWER(SIN((#{latitude} - #{geocoder_latitude_attr}) * " +
          "PI() / 180 / 2), 2) + COS(#{latitude} * PI()/180) * " +
          "COS(#{geocoder_latitude_attr} * PI() / 180) * " +
          "POWER(SIN((#{longitude} - #{geocoder_longitude_attr}) * " +
          "PI() / 180 / 2), 2) )) as distance",
        :conditions => [
          "#{geocoder_latitude_attr} BETWEEN ? AND ? AND " +
          "#{geocoder_longitude_attr} BETWEEN ? AND ?",
          lat_lo, lat_hi, lon_lo, lon_hi],
        :having => "distance <= #{radius}",
        :order  => options[:order],
        :limit  => limit
      }
    end

    ##
    # Name of the method that returns the search string.
    #
    def geocoder_method_name
      defined?(@geocoder_method_name) ?
        @geocoder_method_name : :location
    end
    
    ##
    # Name of the latitude attribute.
    #
    def geocoder_latitude_attr
      defined?(@geocoder_latitude_attr) ?
        @geocoder_latitude_attr : :latitude
    end
    
    ##
    # Name of the longitude attribute.
    #
    def geocoder_longitude_attr
      defined?(@geocoder_longitude_attr) ?
        @geocoder_longitude_attr : :longitude
    end
    
    ##
    # Get the coordinates [lat,lon] of an object.
    # This seems cleaner than polluting the object method namespace.
    #
    def get_coordinates_of(object)
      [object.send(geocoder_latitude_attr),
      object.send(geocoder_longitude_attr)]
    end
  end
  
  ##
  # Is this object geocoded? (Does it have latitude and longitude?)
  #
  def geocoded?
    self.class.get_coordinates_of(self).compact.size > 0
  end
  
  ##
  # Calculate the distance from the object to a point (lat,lon). Valid units
  # are defined in <tt>distance_between</tt> class method.
  #
  def distance_to(lat, lon, units = :mi)
    return nil unless geocoded?
    mylat,mylon = self.class.get_coordinates_of(self)
    Geocoder.distance_between(mylat, mylon, lat, lon, :units => units)
  end
  
  ##
  # Get other geocoded objects within a given radius.
  # The object must be geocoded before this method is called.
  #
  def nearbys(radius = 20)
    return [] unless geocoded?
    lat,lon = self.class.get_coordinates_of(self)
    self.class.find_near([lat, lon], radius) - [self]
  end
  
  ##
  # Fetch coordinates based on the object's location.
  # Returns an array <tt>[lat,lon]</tt>.
  #
  def fetch_coordinates
    location = read_attribute(self.class.geocoder_method_name)
    Geocoder.fetch_coordinates(location)
  end
  
  ##
  # Fetch coordinates and assign +latitude+ and +longitude+.
  #
  def fetch_coordinates!
    returning fetch_coordinates do |c|
      unless c.blank?
        write_attribute(self.class.geocoder_latitude_attr, c[0])
        write_attribute(self.class.geocoder_longitude_attr, c[1])
      end
    end
  end

  ##
  # Query Google for the coordinates of the given phrase.
  # Returns array [lat,lon] if found, nil if not found or if network error.
  #
  def self.fetch_coordinates(query)
    return nil unless doc = self.search(query)
    
    # Make sure search found a result.
    e = doc.elements['kml/Response/Status/code']
    return nil unless (e and e.text == "200")
    
    # Isolate the relevant part of the result.
    place = doc.elements['kml/Response/Placemark']

    # If there are multiple results, blindly use the first.
    coords = place.elements['Point/coordinates'].text
    coords.split(',')[0...2].reverse.map{ |i| i.to_f }
  end
  
  ##
  # Calculate the distance between two points on Earth (Haversine formula).
  # Takes two sets of coordinates and an options hash:
  # 
  # +units+ :: <tt>:mi</tt> for miles (default), <tt>:km</tt> for kilometers
  #
  def self.distance_between(lat1, lon1, lat2, lon2, options = {})
    # set default options
    options[:units] ||= :mi
    # define available units
    units = { :mi => 3956, :km => 6371 }
    
    # convert degrees to radians
    lat1 = to_radians(lat1)
    lon1 = to_radians(lon1)
    lat2 = to_radians(lat2)
    lon2 = to_radians(lon2)
    # compute distances
    dlat = (lat1 - lat2).abs
    dlon = (lon1 - lon2).abs

    a = (Math.sin(dlat / 2))**2 + Math.cos(lat1) *
        (Math.sin(dlon / 2))**2 * Math.cos(lat2)  
    c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))  
    c * units[options[:units]]
  end
  
  ##
  # Convert degrees to radians.
  #
  def self.to_radians(degrees)
    degrees * (Math::PI / 180)
  end
  
  ##
  # Query Google for geographic information about the given phrase.
  # Returns the XML response as a hash. This method is not intended for
  # general use (prefer Geocoder.search).
  #
  def self.search(query)
    params = { :q => query, :output => "xml" }
    url    = "http://maps.google.com/maps/geo?" + params.to_query
    
    # Query geocoder and make sure it responds quickly.
    begin
      resp = nil
      timeout(3) do
        resp = Net::HTTP.get_response(URI.parse(url))
      end
    rescue SocketError, TimeoutError
      return nil
    end

    # Google's XML document has incorrect encoding (says UTF-8 but is actually
    # ISO 8859-1). Have to fix this or REXML won't parse correctly.
    # This may be fixed in the future; see the bug report at:
    # http://code.google.com/p/gmaps-api-issues/issues/detail?id=233
    doc = resp.body.sub('UTF-8', 'ISO-8859-1')

    REXML::Document.new(doc)
  end
end
