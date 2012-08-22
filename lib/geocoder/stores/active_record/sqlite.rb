module Geocoder::Store
  module ActiveRecord::Sqlite
    ##
    # Scope options hash for use with a database without trigonometric
    # functions, like SQLite. Approach is to find objects within a square
    # rather than a circle, so results are very approximate (will include
    # objects outside the given radius).
    #
    # Distance and bearing calculations are *extremely inaccurate*. They
    # only exist for interface consistency--not intended for production!
    #
    def near_scope_options(latitude, longitude, radius, options)
      lat_attr = geocoder_options[:latitude]
      lon_attr = geocoder_options[:longitude]
      unless options.include?(:bearing)
        options[:bearing] = (options[:method] || \
                             geocoder_options[:method] || \
                             Geocoder::Configuration.distances)
      end
      if options[:bearing]
        bearing = "CASE " +
          "WHEN (#{full_column_name(lat_attr)} >= #{latitude} AND #{full_column_name(lon_attr)} >= #{longitude}) THEN  45.0 " +
          "WHEN (#{full_column_name(lat_attr)} <  #{latitude} AND #{full_column_name(lon_attr)} >= #{longitude}) THEN 135.0 " +
          "WHEN (#{full_column_name(lat_attr)} <  #{latitude} AND #{full_column_name(lon_attr)} <  #{longitude}) THEN 225.0 " +
          "WHEN (#{full_column_name(lat_attr)} >= #{latitude} AND #{full_column_name(lon_attr)} <  #{longitude}) THEN 315.0 " +
        "END"
      else
        bearing = false
      end

      distance = approx_distance_from_sql(latitude, longitude, options)
      options[:units] ||= (geocoder_options[:units] || Geocoder::Configuration.units)

      b = Geocoder::Calculations.bounding_box([latitude, longitude], radius, options)
      conditions = [
        "#{full_column_name(lat_attr)} BETWEEN ? AND ? AND #{full_column_name(lon_attr)} BETWEEN ? AND ?"] +
        [b[0], b[2], b[1], b[3]
      ]
      default_near_scope_options(latitude, longitude, radius, options).merge(
        :select => "#{options[:select] || full_column_name("*")}, " +
          "#{distance} AS distance" +
          (bearing ? ", #{bearing} AS bearing" : ""),
        :conditions => add_exclude_condition(conditions, options[:exclude])
      )
    end

    def distance_from_sql(latitude, longitude, options)
      lat_attr = geocoder_options[:latitude]
      lon_attr = geocoder_options[:longitude]

      dx = Geocoder::Calculations.longitude_degree_distance(30, options[:units] || :mi)
      dy = Geocoder::Calculations.latitude_degree_distance(options[:units] || :mi)

      # sin of 45 degrees = average x or y component of vector
      factor = Math.sin(Math::PI / 4)

      "(#{dy} * ABS(#{full_column_name(lat_attr)} - #{latitude}) * #{factor}) + " +
        "(#{dx} * ABS(#{full_column_name(lon_attr)} - #{longitude}) * #{factor})"
    end

    ##
    # Value which can be passed to where() to produce no results.
    #
    def false_condition
      0
    end
  end
end
