module Geocoder
  module Calculations
    extend self

    ##
    # Compass point names, listed clockwise starting at North.
    #
    # If you want bearings named using more, fewer, or different points
    # override Geocoder::Calculations.COMPASS_POINTS with your own array.
    #
    COMPASS_POINTS = %w[N NE E SE S SW W NW]

    ##
    # Radius of the Earth, in kilometers.
    # Value taken from: http://en.wikipedia.org/wiki/Earth_radius
    #
    EARTH_RADIUS = 6371.0

    ##
    # Conversion factor: multiply by kilometers to get miles.
    #
    KM_IN_MI = 0.621371192

    ##
    # Calculate the distance spanned by one
    # degree of latitude in the given units.
    #
    def latitude_degree_distance(units = :mi)
      2 * Math::PI * earth_radius(units) / 360
    end

    ##
    # Calculate the distance spanned by one degree of longitude
    # at the given latitude. This ranges from around 69 miles at
    # the equator to zero at the poles.
    #
    def longitude_degree_distance(latitude, units = :mi)
      latitude_degree_distance(units) * Math.cos(to_radians(latitude))
    end

    ##
    # Calculate the distance between two points on Earth (Haversine formula).
    # Takes two sets of coordinates and an options hash:
    #
    # * <tt>:units</tt> - <tt>:mi</tt> (default) or <tt>:km</tt>
    #
    def distance_between(lat1, lon1, lat2, lon2, options = {})

      # set default options
      options[:units] ||= :mi

      # convert degrees to radians
      lat1, lon1, lat2, lon2 = to_radians(lat1, lon1, lat2, lon2)

      # compute deltas
      dlat = lat2 - lat1
      dlon = lon2 - lon1

      a = (Math.sin(dlat / 2))**2 + Math.cos(lat1) *
          (Math.sin(dlon / 2))**2 * Math.cos(lat2)
      c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
      c * earth_radius(options[:units])
    end

    ##
    # Calculate bearing between two sets of coordinates.
    # Returns a number of degrees from due north (clockwise).
    #
    # Also accepts an options hash:
    #
    # * <tt>:method</tt> - <tt>:linear</tt> (default) or <tt>:spherical</tt>;
    #   the spherical method is "correct" in that it returns the shortest path
    #   (one along a great circle) but the linear method is the default as it
    #   is less confusing (returns due east or west when given two points with
    #   the same latitude)
    #
    # Based on: http://www.movable-type.co.uk/scripts/latlong.html
    #
    def bearing_between(lat1, lon1, lat2, lon2, options = {})
      options[:method] = :linear unless options[:method] == :spherical

      # convert degrees to radians
      lat1, lon1, lat2, lon2 = to_radians(lat1, lon1, lat2, lon2)

      # compute deltas
      dlat = lat2 - lat1
      dlon = lon2 - lon1

      case options[:method]
      when :linear
        y = dlon
        x = dlat

      when :spherical
        y = Math.sin(dlon) * Math.cos(lat2)
        x = Math.cos(lat1) * Math.sin(lat2) -
            Math.sin(lat1) * Math.cos(lat2) * Math.cos(dlon)
      end

      bearing = Math.atan2(x,y)
      # Answer is in radians counterclockwise from due east.
      # Convert to degrees clockwise from due north:
      (90 - to_degrees(bearing) + 360) % 360
    end

    ##
    # Translate a bearing (float) into a compass direction (string, eg "North").
    #
    def compass_point(bearing, points = COMPASS_POINTS)
      seg_size = 360 / points.size
      points[((bearing + (seg_size / 2)) % 360) / seg_size]
    end

    ##
    # Compute the geographic center (aka geographic midpoint, center of
    # gravity) for an array of geocoded objects and/or [lat,lon] arrays
    # (can be mixed). Any objects missing coordinates are ignored. Follows
    # the procedure documented at http://www.geomidpoint.com/calculation.html.
    #
    def geographic_center(points)

      # convert objects to [lat,lon] arrays and remove nils
      points.map!{ |p| p.is_a?(Array) ? p : p.to_coordinates }.compact

      # convert degrees to radians
      points.map!{ |p| to_radians(p) }

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
      to_degrees [lat, lon]
    end

    ##
    # Returns coordinates of the lower-left and upper-right corners of a box
    # with the given point at its center. The radius is the shortest distance
    # from the center point to any side of the box (the length of each side
    # is twice the radius).
    #
    # This is useful for finding corner points of a map viewport, or for
    # roughly limiting the possible solutions in a geo-spatial search
    # (ActiveRecord queries use it thusly).
    #
    def bounding_box(latitude, longitude, radius, options = {})
      units = options[:units] || :mi
      radius = radius.to_f
      [
        latitude  - (radius / latitude_degree_distance(units)),
        longitude - (radius / longitude_degree_distance(latitude, units)),
        latitude  + (radius / latitude_degree_distance(units)),
        longitude + (radius / longitude_degree_distance(latitude, units))
      ]
    end

    ##
    # Convert degrees to radians.
    # If an array (or multiple arguments) is passed,
    # converts each value and returns array.
    #
    def to_radians(*args)
      args = args.first if args.first.is_a?(Array)
      if args.size == 1
        args.first * (Math::PI / 180)
      else
        args.map{ |i| to_radians(i) }
      end
    end

    ##
    # Convert radians to degrees.
    # If an array (or multiple arguments) is passed,
    # converts each value and returns array.
    #
    def to_degrees(*args)
      args = args.first if args.first.is_a?(Array)
      if args.size == 1
        (args.first * 180.0) / Math::PI
      else
        args.map{ |i| to_degrees(i) }
      end
    end

    ##
    # Convert miles to kilometers.
    #
    def to_kilometers(mi)
      mi * mi_in_km
    end

    ##
    # Convert kilometers to miles.
    #
    def to_miles(km)
      km * km_in_mi
    end

    ##
    # Radius of the Earth in the given units (:mi or :km). Default is :mi.
    #
    def earth_radius(units = :mi)
      units == :km ? EARTH_RADIUS : to_miles(EARTH_RADIUS)
    end

    ##
    # Conversion factor: km to mi.
    #
    def km_in_mi
      KM_IN_MI
    end

    ##
    # Conversion factor: mi to km.
    #
    def mi_in_km
      1.0 / KM_IN_MI
    end
  end
end
