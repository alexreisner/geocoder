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
    # Conversion factor: multiply by nautical miles to get miles.
    #
    KM_IN_NM = 0.539957

    # Not a number constant
    NAN = defined?(::Float::NAN) ? ::Float::NAN : 0 / 0.0

    ##
    # Returns true if all given arguments are valid latitude/longitude values.
    #
    def coordinates_present?(*args)
      args.each do |a|
        # note that Float::NAN != Float::NAN
        # still, this could probably be improved:
        return false if (!a.is_a?(Numeric) or a.to_s == "NaN")
      end
      true
    end

    ##
    # Distance spanned by one degree of latitude in the given units.
    #
    def latitude_degree_distance(units = nil)
      units ||= Geocoder.config.units
      2 * Math::PI * earth_radius(units) / 360
    end

    ##
    # Distance spanned by one degree of longitude at the given latitude.
    # This ranges from around 69 miles at the equator to zero at the poles.
    #
    def longitude_degree_distance(latitude, units = nil)
      units ||= Geocoder.config.units
      latitude_degree_distance(units) * Math.cos(to_radians(latitude))
    end

    ##
    # Distance between two points on Earth (Haversine formula).
    # Takes two points and an options hash.
    # The points are given in the same way that points are given to all
    # Geocoder methods that accept points as arguments. They can be:
    #
    # * an array of coordinates ([lat,lon])
    # * a geocodable address (string)
    # * a geocoded object (one which implements a +to_coordinates+ method
    #   which returns a [lat,lon] array
    #
    # The options hash supports:
    #
    # * <tt>:units</tt> - <tt>:mi</tt> or <tt>:km</tt>
    #   Use Geocoder.configure(:units => ...) to configure default units.
    #
    def distance_between(point1, point2, options = {})

      # set default options
      options[:units] ||= Geocoder.config.units

      # convert to coordinate arrays
      point1 = extract_coordinates(point1)
      point2 = extract_coordinates(point2)

      # convert degrees to radians
      point1 = to_radians(point1)
      point2 = to_radians(point2)

      # compute deltas
      dlat = point2[0] - point1[0]
      dlon = point2[1] - point1[1]

      a = (Math.sin(dlat / 2))**2 + Math.cos(point1[0]) *
          (Math.sin(dlon / 2))**2 * Math.cos(point2[0])
      c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
      c * earth_radius(options[:units])
    end

    ##
    # Bearing between two points on Earth.
    # Returns a number of degrees from due north (clockwise).
    #
    # See Geocoder::Calculations.distance_between for
    # ways of specifying the points. Also accepts an options hash:
    #
    # * <tt>:method</tt> - <tt>:linear</tt> or <tt>:spherical</tt>;
    #   the spherical method is "correct" in that it returns the shortest path
    #   (one along a great circle) but the linear method is less confusing
    #   (returns due east or west when given two points with the same latitude).
    #   Use Geocoder.configure(:distances => ...) to configure calculation method.
    #
    # Based on: http://www.movable-type.co.uk/scripts/latlong.html
    #
    def bearing_between(point1, point2, options = {})

      # set default options
      options[:method] ||= Geocoder.config.distances
      options[:method] = :linear unless options[:method] == :spherical

      # convert to coordinate arrays
      point1 = extract_coordinates(point1)
      point2 = extract_coordinates(point2)

      # convert degrees to radians
      point1 = to_radians(point1)
      point2 = to_radians(point2)

      # compute deltas
      dlat = point2[0] - point1[0]
      dlon = point2[1] - point1[1]

      case options[:method]
      when :linear
        y = dlon
        x = dlat

      when :spherical
        y = Math.sin(dlon) * Math.cos(point2[0])
        x = Math.cos(point1[0]) * Math.sin(point2[0]) -
            Math.sin(point1[0]) * Math.cos(point2[0]) * Math.cos(dlon)
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

      # convert objects to [lat,lon] arrays and convert degrees to radians
      coords = points.map{ |p| to_radians(extract_coordinates(p)) }

      # convert to Cartesian coordinates
      x = []; y = []; z = []
      coords.each do |p|
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
    # Returns coordinates of the southwest and northeast corners of a box
    # with the given point at its center. The radius is the shortest distance
    # from the center point to any side of the box (the length of each side
    # is twice the radius).
    #
    # This is useful for finding corner points of a map viewport, or for
    # roughly limiting the possible solutions in a geo-spatial search
    # (ActiveRecord queries use it thusly).
    #
    # See Geocoder::Calculations.distance_between for
    # ways of specifying the point. Also accepts an options hash:
    #
    # * <tt>:units</tt> - <tt>:mi</tt> or <tt>:km</tt>.
    #   Use Geocoder.configure(:units => ...) to configure default units.
    #
    def bounding_box(point, radius, options = {})
      lat,lon = extract_coordinates(point)
      radius  = radius.to_f
      units   = options[:units] || Geocoder.config.units
      [
        lat - (radius / latitude_degree_distance(units)),
        lon - (radius / longitude_degree_distance(lat, units)),
        lat + (radius / latitude_degree_distance(units)),
        lon + (radius / longitude_degree_distance(lat, units))
      ]
    end

    ##
    # Random point within a circle of provided radius centered
    # around the provided point
    # Takes one point, one radius, and an options hash.
    # The points are given in the same way that points are given to all
    # Geocoder methods that accept points as arguments. They can be:
    #
    # * an array of coordinates ([lat,lon])
    # * a geocodable address (string)
    # * a geocoded object (one which implements a +to_coordinates+ method
    #   which returns a [lat,lon] array
    #
    # The options hash supports:
    #
    # * <tt>:units</tt> - <tt>:mi</tt> or <tt>:km</tt>
    #   Use Geocoder.configure(:units => ...) to configure default units.
    def random_point_near(center, radius, options = {})

      # set default options
      options[:units] ||= Geocoder.config.units

      # convert to coordinate arrays
      center = extract_coordinates(center)

      earth_circumference = 2 * Math::PI * earth_radius(options[:units])
      max_degree_delta =  360.0 * (radius / earth_circumference)

      # random bearing in radians
      theta = 2 * Math::PI * rand

      # random radius, use the square root to ensure a uniform
      # distribution of points over the circle
      r = Math.sqrt(rand) * max_degree_delta

      delta_lat, delta_long = [r * Math.cos(theta), r * Math.sin(theta)]
      [center[0] + delta_lat, center[1] + delta_long]
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

    def distance_to_radians(distance, units = nil)
      units ||= Geocoder.config.units
      distance.to_f / earth_radius(units)
    end

    def radians_to_distance(radians, units = nil)
      units ||= Geocoder.config.units
      radians * earth_radius(units)
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
    # Convert kilometers to nautical miles.
    #
    def to_nautical_miles(km)
      km * km_in_nm
    end

    ##
    # Radius of the Earth in the given units (:mi or :km).
    # Use Geocoder.configure(:units => ...) to configure default units.
    #
    def earth_radius(units = nil)
      units ||= Geocoder.config.units
      case units
        when :km; EARTH_RADIUS
        when :mi; to_miles(EARTH_RADIUS)
        when :nm; to_nautical_miles(EARTH_RADIUS)
      end
    end

    ##
    # Conversion factor: km to mi.
    #
    def km_in_mi
      KM_IN_MI
    end

    ##
    # Conversion factor: km to nm.
    #
    def km_in_nm
      KM_IN_NM
    end



    ##
    # Conversion factor: mi to km.
    #
    def mi_in_km
      1.0 / KM_IN_MI
    end

    ##
    # Conversion factor: nm to km.
    #
    def nm_in_km
      1.0 / KM_IN_NM
    end

    ##
    # Takes an object which is a [lat,lon] array, a geocodable string,
    # or an object that implements +to_coordinates+ and returns a
    # [lat,lon] array. Note that if a string is passed this may be a slow-
    # running method and may return nil.
    #
    def extract_coordinates(point)
      case point
      when Array
        if point.size == 2
          lat, lon = point
          if !lat.nil? && lat.respond_to?(:to_f) and
            !lon.nil? && lon.respond_to?(:to_f)
          then
            return [ lat.to_f, lon.to_f ]
          end
        end
      when String
        point = Geocoder.coordinates(point) and return point
      else
        if point.respond_to?(:to_coordinates)
          if Array === array = point.to_coordinates
            return extract_coordinates(array)
          end
        end
      end
      [ NAN, NAN ]
    end
  end
end

