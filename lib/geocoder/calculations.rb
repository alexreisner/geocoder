module Geocoder
  module Calculations
    extend self

    ##
    # Calculate the distance between two points on Earth (Haversine formula).
    # Takes two sets of coordinates and an options hash:
    #
    # <tt>:units</tt> :: <tt>:mi</tt> (default) or <tt>:km</tt>
    #
    def distance_between(lat1, lon1, lat2, lon2, options = {})

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
    def geographic_center(points)

      # convert objects to [lat,lon] arrays and remove nils
      points.map!{ |p| p.is_a?(Array) ? p : p.to_coordinates }.compact

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
    def to_radians(degrees)
      degrees * (Math::PI / 180)
    end

    ##
    # Convert radians to degrees.
    #
    def to_degrees(radians)
      (radians * 180.0) / Math::PI
    end

    ##
    # Conversion factor: km to mi.
    #
    def km_in_mi
      0.621371192
    end

    ##
    # Calculate bearing between two sets of co-ordinates
    #
    def bearing_between(lat1, lon1, lat2, lon2, options = {})
      # Math courtesy of http://www.movable-type.co.uk/scripts/latlong.html
      dlon = to_radians((lon1 - lon2).abs)

      y = Math.sin(dlon) * Math.cos(lat2)
      x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dlon)
      brng = Math.atan2(x,y)
      (to_degrees(brng) + 360) % 360
    end

    # If you want more or fewer points simply override Geocoder::Calculations.COMPASS_POINTS with your own array
    COMPASS_POINTS = [{:name => "North", :abbr => "N"},
                      {:name => "North East", :abbr => "NE"},
                      {:name => "East", :abbr => "E"},
                      {:name => "South East", :abbr => "SE"},
                      {:name => "South", :abbr => "S"},
                      {:name => "South West", :abbr => "SW"},
                      {:name => "West", :abbr => "W"},
                      {:name => "North West", :abbr => "NW"}]

    ##
    # Compass direction (North, South, etc.) between two sets of co-ordinates
    def compass_point(bearing, points = COMPASS_POINTS)
      seg_size = 360/points.length
      points[((bearing + (seg_size/2) ) % 360) / seg_size]
    end
  end
end
