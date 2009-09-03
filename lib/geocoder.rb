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
  # Query Google for the coordinates of the given phrase.
  # Returns array [lat,lon] if found, nil if not found or if network error.
  #
  def self.fetch_coordinates(query)
    doc = self.search(query)
    
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
  # Methods which will be class methods of the including class.
  #
  module ClassMethods

    ##
    # Find all objects within a radius (in miles) of the given location
    # (address string).
    #
    def near(location, radius = 100, options = {})
      latitude, longitude = Geocoder.fetch_coordinates(location)
      return [] unless (latitude and longitude)
      query = nearby_mysql_query(latitude, longitude, radius.to_i, options)
      find_by_sql(query)
    end
    
    ##
    # Generate a MySQL query to find all records within a radius (in miles)
    # of a point.
    #
    def nearby_mysql_query(latitude, longitude, radius = 20, options = {})
      table = options[:table_name] || self.to_s.tableize
      options.delete :table_name # don't pass to nearby_mysql_query
      Geocoder.nearby_mysql_query(table, latitude, longitude, radius, options)
    end
      
    ##
    # Get the name of the method that returns the search string.
    #
    def geocoder_method_name
      defined?(@geocoder_method_name) ? @geocoder_method_name : :location
    end
  end
  
  ##
  # Calculate the distance from the object to a point (lat,lon). Valid units
  # are defined in <tt>distance_between</tt> class method.
  #
  def distance_to(lat, lon, units = :mi)
    Geocoder.distance_between(latitude, longitude, lat, lon, :units => units)
  end
  
  ##
  # Fetch coordinates based on the object's object's +location+. Returns an
  # array <tt>[lat,lon]</tt>.
  #
  def fetch_coordinates
    Geocoder.fetch_coordinates(send(self.class.geocoder_method_name))
  end
  
  ##
  # Fetch and assign +latitude+ and +longitude+.
  #
  def fetch_and_assign_coordinates
    returning fetch_coordinates do |c|
      unless c.blank?
        self.latitude = c[0]
        self.longitude = c[1]
      end
    end
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
    lat1 *= Math::PI / 180
    lon1 *= Math::PI / 180
    lat2 *= Math::PI / 180
    lon2 *= Math::PI / 180
    dlat = (lat1 - lat2).abs
    dlon = (lon1 - lon2).abs

    a = (Math.sin(dlat / 2))**2 + Math.cos(lat1) *
        (Math.sin(dlon / 2))**2 * Math.cos(lat2)  
    c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))  
    c * units[options[:units]]
  end
  
  ##
  # Find all records within a radius (in miles) of the given point.
  # Taken from excellent tutorial at:
  # http://www.scribd.com/doc/2569355/Geo-Distance-Search-with-MySQL
  # 
  # Options hash may include:
  # 
  # +latitude+  :: name of column storing latitude data
  # +longitude+ :: name of column storing longitude data
  # +order+     :: column(s) for ORDER BY SQL clause
  # +limit+     :: number of records to return (for LIMIT SQL clause)
  # +offset+    :: number of records to skip (for LIMIT SQL clause)
  #
  def self.nearby_mysql_query(table, latitude, longitude, radius = 20, options = {})
    
    # Alternate column names.
    options[:latitude]  ||= 'latitude'
    options[:longitude] ||= 'longitude'
    options[:order]     ||= 'distance ASC'
    
    # Constrain search to a (radius x radius) square.
    factor = (Math::cos(latitude * Math::PI / 180.0) * 69.0).abs
    lon_lo = longitude - (radius / factor);
    lon_hi = longitude + (radius / factor);
    lat_lo = latitude  - (radius / 69.0);
    lat_hi = latitude  + (radius / 69.0);
    where  = "#{options[:latitude]} BETWEEN #{lat_lo} AND #{lat_hi} AND " +
      "#{options[:longitude]} BETWEEN #{lon_lo} AND #{lon_hi}"
    
    # Build limit clause.
    limit = ""
    if options[:limit] or options[:offset]
      options[:offset] ||= 0
      limit = "LIMIT #{options[:offset]},#{options[:limit]}"
    end

    # Generate query.
    "SELECT *, 3956 * 2 * ASIN(SQRT(" +
      "POWER(SIN((#{latitude} - #{options[:latitude]}) * " +
      "PI() / 180 / 2), 2) + COS(#{latitude} * PI()/180) * " +
      "COS(#{options[:latitude]} * PI() / 180) * " +
      "POWER(SIN((#{longitude} - #{options[:longitude]}) * " +
      "PI() / 180 / 2), 2) )) as distance " +
      "FROM #{table} WHERE #{where} HAVING distance <= #{radius} " +
      "ORDER BY #{options[:order]} #{limit}"
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
