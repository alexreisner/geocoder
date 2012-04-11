require 'geocoder/stores/base'

##
# Add geocoding functionality to any ActiveRecord object.
#
module Geocoder::Store
  module ActiveRecord
    include Base

    ##
    # Implementation of 'included' hook method.
    #
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do

        # scope: geocoded objects
        scope :geocoded, lambda {
          {:conditions => "#{geocoder_options[:latitude]} IS NOT NULL " +
            "AND #{geocoder_options[:longitude]} IS NOT NULL"}}

        # scope: not-geocoded objects
        scope :not_geocoded, lambda {
          {:conditions => "#{geocoder_options[:latitude]} IS NULL " +
            "OR #{geocoder_options[:longitude]} IS NULL"}}

        ##
        # Find all objects within a radius of the given location.
        # Location may be either a string to geocode or an array of
        # coordinates (<tt>[lat,lon]</tt>). Also takes an options hash
        # (see Geocoder::Orm::ActiveRecord::ClassMethods.near_scope_options
        # for details).
        #
        scope :near, lambda{ |location, *args|
          latitude, longitude = Geocoder::Calculations.extract_coordinates(location)
          if latitude and longitude
            near_scope_options(latitude, longitude, *args)
          else
            where(false_condition) # no results if no lat/lon given
          end
        }


        ##
        # Find all objects within the area of a given bounding box.
        # Bounds must be an array of locations specifying the southwest
        # corner followed by the northeast corner of the box
        # (<tt>[[sw_lat, sw_lon], [ne_lat, ne_lon]]</tt>).
        #
        scope :within_bounding_box, lambda{ |bounds|
          sw_lat, sw_lng, ne_lat, ne_lng = bounds.flatten if bounds
          return where(false_condition) unless sw_lat && sw_lng && ne_lat && ne_lng
          spans = "#{geocoder_options[:latitude]} BETWEEN #{sw_lat} AND #{ne_lat} AND "
          spans << if sw_lng > ne_lng   # Handle a box that spans 180
            "#{geocoder_options[:longitude]} BETWEEN #{sw_lng} AND 180 OR #{geocoder_options[:longitude]} BETWEEN -180 AND #{ne_lng}"
          else
            "#{geocoder_options[:longitude]} BETWEEN #{sw_lng} AND #{ne_lng}"
          end
          { :conditions => spans }
        }
      end
    end

    ##
    # Methods which will be class methods of the including class.
    #
    module ClassMethods

      def distance_from_sql(location, *args)
        latitude, longitude = Geocoder::Calculations.extract_coordinates(location)
        distance_from_sql_options(latitude, longitude, *args) if latitude and longitude
      end

      private # ----------------------------------------------------------------

      ##
      # Get options hash suitable for passing to ActiveRecord.find to get
      # records within a radius (in miles) of the given point.
      # Options hash may include:
      #
      # * +:units+   - <tt>:mi</tt> (default) or <tt>:km</tt>; to be used
      #   for interpreting radius as well as the +distance+ attribute which
      #   is added to each found nearby object
      # * +:bearing+ - <tt>:linear</tt> (default) or <tt>:spherical</tt>;
      #   the method to be used for calculating the bearing (direction)
      #   between the given point and each found nearby point;
      #   set to false for no bearing calculation
      # * +:select+  - string with the SELECT SQL fragment (e.g. “id, name”)
      # * +:order+   - column(s) for ORDER BY SQL clause; default is distance
      # * +:exclude+ - an object to exclude (used by the +nearbys+ method)
      #
      def near_scope_options(latitude, longitude, radius = 20, options = {})
        if using_sqlite?
          approx_near_scope_options(latitude, longitude, radius, options)
        else
          full_near_scope_options(latitude, longitude, radius, options)
        end
      end

      def distance_from_sql_options(latitude, longitude, options = {})
        if using_sqlite?
          approx_distance_from_sql(latitude, longitude, options)
        else
          full_distance_from_sql(latitude, longitude, options)
        end
      end

      ##
      # Scope options hash for use with a database that supports POWER(),
      # SQRT(), PI(), and trigonometric functions SIN(), COS(), ASIN(),
      # ATAN2(), DEGREES(), and RADIANS().
      #
      # Bearing calculation based on:
      # http://www.beginningspatial.com/calculating_bearing_one_point_another
      #
      def full_near_scope_options(latitude, longitude, radius, options)
        lat_attr = geocoder_options[:latitude]
        lon_attr = geocoder_options[:longitude]
        options[:bearing] = :linear unless options.include?(:bearing)
        bearing = case options[:bearing]
        when :linear
          "CAST(" +
            "DEGREES(ATAN2( " +
              "RADIANS(#{lon_attr} - #{longitude}), " +
              "RADIANS(#{lat_attr} - #{latitude})" +
            ")) + 360 " +
          "AS decimal) % 360"
        when :spherical
          "CAST(" +
            "DEGREES(ATAN2( " +
              "SIN(RADIANS(#{lon_attr} - #{longitude})) * " +
              "COS(RADIANS(#{lat_attr})), (" +
                "COS(RADIANS(#{latitude})) * SIN(RADIANS(#{lat_attr}))" +
              ") - (" +
                "SIN(RADIANS(#{latitude})) * COS(RADIANS(#{lat_attr})) * " +
                "COS(RADIANS(#{lon_attr} - #{longitude}))" +
              ")" +
            ")) + 360 " +
          "AS decimal) % 360"
        end

        distance = full_distance_from_sql(latitude, longitude, options)
        conditions = ["#{distance} <= ?", radius]
        default_near_scope_options(latitude, longitude, radius, options).merge(
          :select => "#{options[:select] || full_column_name("*")}, " +
            "#{distance} AS distance" +
            (bearing ? ", #{bearing} AS bearing" : ""),
          :conditions => add_exclude_condition(conditions, options[:exclude])
        )
      end


      # Distance calculations based on the excellent tutorial at:
      # http://www.scribd.com/doc/2569355/Geo-Distance-Search-with-MySQL

      def full_distance_from_sql(latitude, longitude, options)
        lat_attr = geocoder_options[:latitude]
        lon_attr = geocoder_options[:longitude]

        earth = Geocoder::Calculations.earth_radius(options[:units] || Geocoder::Configuration.units)

        "#{earth} * 2 * ASIN(SQRT(" +
          "POWER(SIN((#{latitude} - #{full_column_name(lat_attr)}) * PI() / 180 / 2), 2) + " +
          "COS(#{latitude} * PI() / 180) * COS(#{full_column_name(lat_attr)} * PI() / 180) * " +
          "POWER(SIN((#{longitude} - #{full_column_name(lon_attr)}) * PI() / 180 / 2), 2) ))"
      end

      def approx_distance_from_sql(latitude, longitude, options)
        lat_attr = geocoder_options[:latitude]
        lon_attr = geocoder_options[:longitude]

        dx = Geocoder::Calculations.longitude_degree_distance(30, options[:units] || Geocoder::Configuration.units)
        dy = Geocoder::Calculations.latitude_degree_distance(options[:units] || Geocoder::Configuration.units)

        # sin of 45 degrees = average x or y component of vector
        factor = Math.sin(Math::PI / 4)

        "(#{dy} * ABS(#{full_column_name(lat_attr)} - #{latitude}) * #{factor}) + " +
          "(#{dx} * ABS(#{full_column_name(lon_attr)} - #{longitude}) * #{factor})"
      end

      ##
      # Scope options hash for use with a database without trigonometric
      # functions, like SQLite. Approach is to find objects within a square
      # rather than a circle, so results are very approximate (will include
      # objects outside the given radius).
      #
      # Distance and bearing calculations are *extremely inaccurate*. They
      # only exist for interface consistency--not intended for production!
      #
      def approx_near_scope_options(latitude, longitude, radius, options)
        lat_attr = geocoder_options[:latitude]
        lon_attr = geocoder_options[:longitude]
        options[:bearing] = :linear unless options.include?(:bearing)
        if options[:bearing]
          bearing = "CASE " +
            "WHEN (#{lat_attr} >= #{latitude} AND #{lon_attr} >= #{longitude}) THEN  45.0 " +
            "WHEN (#{lat_attr} <  #{latitude} AND #{lon_attr} >= #{longitude}) THEN 135.0 " +
            "WHEN (#{lat_attr} <  #{latitude} AND #{lon_attr} <  #{longitude}) THEN 225.0 " +
            "WHEN (#{lat_attr} >= #{latitude} AND #{lon_attr} <  #{longitude}) THEN 315.0 " +
          "END"
        else
          bearing = false
        end

        distance = approx_distance_from_sql(latitude, longitude, options)

        b = Geocoder::Calculations.bounding_box([latitude, longitude], radius, options)
        conditions = [
          "#{lat_attr} BETWEEN ? AND ? AND #{lon_attr} BETWEEN ? AND ?"] +
          [b[0], b[2], b[1], b[3]
        ]
        default_near_scope_options(latitude, longitude, radius, options).merge(
          :select => "#{options[:select] || full_column_name("*")}, " +
            "#{distance} AS distance" +
            (bearing ? ", #{bearing} AS bearing" : ""),
          :conditions => add_exclude_condition(conditions, options[:exclude])
        )
      end

      ##
      # Options used for any near-like scope.
      #
      def default_near_scope_options(latitude, longitude, radius, options)
        {
          :order  => options[:order] || "distance",
          :limit  => options[:limit],
          :offset => options[:offset]
        }
      end

      ##
      # Adds a condition to exclude a given object by ID.
      # The given conditions MUST be an array.
      #
      def add_exclude_condition(conditions, exclude)
        if exclude
          conditions[0] << " AND #{full_column_name(:id)} != ?"
          conditions << exclude.id
        end
        conditions
      end

      def using_sqlite?
        connection.adapter_name.match /sqlite/i
      end

      ##
      # Value which can be passed to where() to produce no results.
      #
      def false_condition
        using_sqlite? ? 0 : "false"
      end

      ##
      # Prepend table name if column name doesn't already contain one.
      #
      def full_column_name(column)
        column = column.to_s
        column.include?(".") ? column : [table_name, column].join(".")
      end
    end

    ##
    # Look up coordinates and assign to +latitude+ and +longitude+ attributes
    # (or other as specified in +geocoded_by+). Returns coordinates (array).
    #
    def geocode
      do_lookup(false) do |o,rs|
        if r = rs.first
          unless r.latitude.nil? or r.longitude.nil?
            o.send :write_attribute, self.class.geocoder_options[:latitude],  r.latitude
            o.send :write_attribute, self.class.geocoder_options[:longitude], r.longitude
          end
          r.coordinates
        end
      end
    end

    alias_method :fetch_coordinates, :geocode

    ##
    # Look up address and assign to +address+ attribute (or other as specified
    # in +reverse_geocoded_by+). Returns address (string).
    #
    def reverse_geocode
      do_lookup(true) do |o,rs|
        if r = rs.first
          unless r.address.nil?
            o.send :write_attribute, self.class.geocoder_options[:fetched_address], r.address
          end
          r.address
        end
      end
    end

    alias_method :fetch_address, :reverse_geocode
  end
end
