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

      # scope: geocoded objects
      scope :geocoded,
        :conditions => "#{geocoder_options[:latitude]} IS NOT NULL " +
          "AND #{geocoder_options[:longitude]} IS NOT NULL"

      # scope: not-geocoded objects
      scope :not_geocoded,
        :conditions => "#{geocoder_options[:latitude]} IS NULL " +
          "OR #{geocoder_options[:longitude]} IS NULL"

      ##
      # Find all objects within a radius (in miles) of the given location
      # (address string). Location (the first argument) may be either a string
      # to geocode or an array of coordinates (<tt>[lat,long]</tt>).
      #
      scope :near, lambda{ |location, *args|
        latitude, longitude = location.is_a?(Array) ?
          location : Geocoder.fetch_coordinates(location)
        if latitude and longitude
          near_scope_options(latitude, longitude, *args)
        else
          {}
        end
      }
    end
  end

  ##
  # Methods which will be class methods of the including class.
  #
  module ClassMethods

    ##
    # Get options hash suitable for passing to ActiveRecord.find to get
    # records within a radius (in miles) of the given point.
    # Options hash may include:
    #
    # +units+   :: <tt>:mi</tt> (default) or <tt>:km</tt>
    # +exclude+ :: an object to exclude (used by the #nearbys method)
    # +order+   :: column(s) for ORDER BY SQL clause
    # +limit+   :: number of records to return (for LIMIT SQL clause)
    # +offset+  :: number of records to skip (for OFFSET SQL clause)
    # +select+  :: string with the SELECT SQL fragment (e.g. “id, name”)
    #
    def near_scope_options(latitude, longitude, radius = 20, options = {})
      radius *= km_in_mi if options[:units] == :km
      if ActiveRecord::Base.connection.adapter_name == "SQLite"
        approx_near_scope_options(latitude, longitude, radius, options)
      else
        full_near_scope_options(latitude, longitude, radius, options)
      end
    end


    private # ----------------------------------------------------------------

    ##
    # Scope options hash for use with a database that supports POWER(),
    # SQRT(), PI(), and trigonometric functions (SIN(), COS(), and ASIN()).
    #
    # Taken from the excellent tutorial at:
    # http://www.scribd.com/doc/2569355/Geo-Distance-Search-with-MySQL
    #
    def full_near_scope_options(latitude, longitude, radius, options)
      lat_attr = geocoder_options[:latitude]
      lon_attr = geocoder_options[:longitude]
      distance = "3956 * 2 * ASIN(SQRT(" +
        "POWER(SIN((#{latitude} - #{lat_attr}) * " +
        "PI() / 180 / 2), 2) + COS(#{latitude} * PI()/180) * " +
        "COS(#{lat_attr} * PI() / 180) * " +
        "POWER(SIN((#{longitude} - #{lon_attr}) * " +
        "PI() / 180 / 2), 2) ))"
      options[:order] ||= "#{distance} ASC"
      default_near_scope_options(latitude, longitude, radius, options).merge(
        :select => "#{options[:select] || '*'}, #{distance} AS distance",
        :having => "#{distance} <= #{radius}"
      )
    end

    ##
    # Scope options hash for use with a database without trigonometric
    # functions, like SQLite. Approach is to find objects within a square
    # rather than a circle, so results are very approximate (will include
    # objects outside the given radius).
    #
    def approx_near_scope_options(latitude, longitude, radius, options)
      default_near_scope_options(latitude, longitude, radius, options).merge(
        :select => options[:select] || nil
      )
    end

    ##
    # Options used for any near-like scope.
    #
    def default_near_scope_options(latitude, longitude, radius, options)
      lat_attr = geocoder_options[:latitude]
      lon_attr = geocoder_options[:longitude]
      conditions = \
        ["#{lat_attr} BETWEEN ? AND ? AND #{lon_attr} BETWEEN ? AND ?"] +
        coordinate_bounds(latitude, longitude, radius)
      if obj = options[:exclude]
        conditions[0] << " AND id != ?"
        conditions << obj.id
      end
      {
        :group  => columns.map{ |c| "#{table_name}.#{c.name}" }.join(','),
        :order  => options[:order],
        :limit  => options[:limit],
        :offset => options[:offset],
        :conditions => conditions
      }
    end

    ##
    # Get the rough high/low lat/long bounds for a geographic point and
    # radius. Returns an array: <tt>[lat_lo, lat_hi, lon_lo, lon_hi]</tt>.
    # Used to constrain search to a (radius x radius) square.
    #
    def coordinate_bounds(latitude, longitude, radius)
      radius = radius.to_f
      factor = (Math::cos(latitude * Math::PI / 180.0) * 69.0).abs
      [
        latitude  - (radius / 69.0),
        latitude  + (radius / 69.0),
        longitude - (radius / factor),
        longitude + (radius / factor)
      ]
    end

    ##
    # Conversion factor: km to mi.
    #
    def km_in_mi
      0.621371192
    end
  end

  ##
  # Read the coordinates [lat,lon] of an object. This is not great but it
  # seems cleaner than polluting the instance method namespace.
  #
  def read_coordinates
    [:latitude, :longitude].map{ |i| send self.class.geocoder_options[i] }
  end

  ##
  # Is this object geocoded? (Does it have latitude and longitude?)
  #
  def geocoded?
    read_coordinates.compact.size > 0
  end

  ##
  # Calculate the distance from the object to a point (lat,lon).
  # Valid units are defined in <tt>distance_between</tt> class method.
  #
  def distance_to(lat, lon, units = :mi)
    return nil unless geocoded?
    mylat,mylon = read_coordinates
    Geocoder.distance_between(mylat, mylon, lat, lon, :units => units)
  end

  ##
  # Get other geocoded objects within a given radius.
  # Valid units are defined in <tt>distance_between</tt> class method.
  #
  def nearbys(radius = 20, units = :mi)
    return [] unless geocoded?
    options = {:exclude => self, :units => units}
    self.class.near(read_coordinates, radius, options)
  end

  ##
  # Fetch coordinates and assign +latitude+ and +longitude+. Also returns
  # coordinates as an array: <tt>[lat, lon]</tt>.
  #
  def fetch_coordinates(save = false)
    coords = Geocoder.fetch_coordinates(
      send(self.class.geocoder_options[:method_name])
    )
    unless coords.blank?
      method = (save ? "update" : "write") + "_attribute"
      send method, self.class.geocoder_options[:latitude],  coords[0]
      send method, self.class.geocoder_options[:longitude], coords[1]
    end
    coords
  end

  ##
  # Fetch coordinates and update (save) +latitude+ and +longitude+ data.
  #
  def fetch_coordinates!
    fetch_coordinates(true)
  end

  ##
  # Calculate the distance between two points on Earth (Haversine formula).
  # Takes two sets of coordinates and an options hash:
  #
  # <tt>:units</tt> :: <tt>:mi</tt> (default) or <tt>:km</tt>
  #
  def self.distance_between(lat1, lon1, lat2, lon2, options = {})

    # set default options
    options[:units] ||= :mi

    # define conversion factors
    conversions = { :mi => 3956, :km => 6371 }

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
    c * conversions[options[:units]]
  end

  ##
  # Compute the geographic center (aka geographic midpoint, center of
  # gravity) for an array of geocoded objects and/or [lat,lon] arrays
  # (can be mixed). Any objects missing coordinates are ignored. Follows
  # the procedure documented at http://www.geomidpoint.com/calculation.html.
  #
  def self.geographic_center(points)

    # convert objects to [lat,lon] arrays and remove nils
    points = points.map{ |p|
      p.is_a?(Array) ? p : (p.geocoded?? p.read_coordinates : nil)
    }.compact

    # convert degrees to radians
    points.map!{ |p| [to_radians(p[0]), to_radians(p[1])] }

    # convert to Cartesian coordinates
    x = []; y = []; z = []
    points.each do |p|
      x << Math.cos(p[0]) * Math.cos(p[1])
      y << Math.cos(p[0]) * Math.sin(p[1])
      z << Math.sin(p[0])
    end

    # compute average coordinate values
    xa, ya, za = [x,y,z].map do |c|
      c.inject(0){ |tot,i| tot += i } / c.size.to_f
    end

    # convert back to latitude/longitude
    lon = Math.atan2(ya, xa)
    hyp = Math.sqrt(xa**2 + ya**2)
    lat = Math.atan2(za, hyp)

    # return answer in degrees
    [to_degrees(lat), to_degrees(lon)]
  end

  ##
  # Convert degrees to radians.
  #
  def self.to_radians(degrees)
    degrees * (Math::PI / 180)
  end

  ##
  # Convert radians to degrees.
  #
  def self.to_degrees(radians)
    (radians * 180.0) / Math::PI
  end

  ##
  # Query Google for geographic information about the given phrase.
  # Returns a hash representing a valid geocoder response.
  # Returns nil if non-200 HTTP response, timeout, or other error.
  #
  def self.search(query)
    doc = _fetch_parsed_response(query)
    doc && doc['status'] == "OK" ? doc : nil
  end

  ##
  # Query Google for the coordinates of the given phrase.
  # Returns array [lat,lon] if found, nil if not found or if network error.
  #
  def self.fetch_coordinates(query)
    return nil unless doc = self.search(query)
    # blindly use the first results (assume they are most accurate)
    place = doc['results'].first['geometry']['location']
    ['lat', 'lng'].map{ |i| place[i] }
  end

  ##
  # Returns a parsed Google geocoder search result (hash).
  # This method is not intended for general use (prefer Geocoder.search).
  #
  def self._fetch_parsed_response(query)
    if doc = _fetch_raw_response(query)
      ActiveSupport::JSON.decode(doc)
    end
  end

  ##
  # Returns a raw Google geocoder search result (JSON).
  # This method is not intended for general use (prefer Geocoder.search).
  #
  def self._fetch_raw_response(query)
    return nil if query.blank?

    # build URL
    params = { :address => query, :sensor  => "false" }
    url = "http://maps.google.com/maps/api/geocode/json?" + params.to_query

    # query geocoder and make sure it responds quickly
    begin
      resp = nil
      timeout(3) do
        Net::HTTP.get_response(URI.parse(url)).body
      end
    rescue SocketError, TimeoutError
      return nil
    end
  end
end

##
# Add geocoded_by method to ActiveRecord::Base so Geocoder is accessible.
#
ActiveRecord::Base.class_eval do

  ##
  # Set attribute names and include the Geocoder module.
  #
  def self.geocoded_by(method_name = :location, options = {})
    class_inheritable_reader :geocoder_options
    write_inheritable_attribute :geocoder_options, {
      :method_name => method_name,
      :latitude    => options[:latitude]  || :latitude,
      :longitude   => options[:longitude] || :longitude
    }
    include Geocoder
  end
end
