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
            where(:id => false) # no results if no lat/lon given
          end
        }
      end
    end

    ##
    # Methods which will be class methods of the including class.
    #
    module ClassMethods

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
        if connection.adapter_name.match /sqlite/i
          approx_near_scope_options(latitude, longitude, radius, options)
        else
          full_near_scope_options(latitude, longitude, radius, options)
        end
      end

      ##
      # Scope options hash for use with a database that supports POWER(),
      # SQRT(), PI(), and trigonometric functions SIN(), COS(), ASIN(),
      # ATAN2(), DEGREES(), and RADIANS().
      #
      # Distance calculations based on the excellent tutorial at:
      # http://www.scribd.com/doc/2569355/Geo-Distance-Search-with-MySQL
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
        earth = Geocoder::Calculations.earth_radius(options[:units] || :mi)
        distance = "#{earth} * 2 * ASIN(SQRT(" +
          "POWER(SIN((#{latitude} - #{lat_attr}) * PI() / 180 / 2), 2) + " +
          "COS(#{latitude} * PI() / 180) * COS(#{lat_attr} * PI() / 180) * " +
          "POWER(SIN((#{longitude} - #{lon_attr}) * PI() / 180 / 2), 2) ))"
        options[:order] ||= "#{distance} ASC"
        default_near_scope_options(latitude, longitude, radius, options).merge(
          :select => "#{options[:select] || '*'}, " +
            "#{distance} AS distance" +
            (bearing ? ", #{bearing} AS bearing" : ""),
          :having => "#{distance} <= #{radius}"
        )
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

        dx = Geocoder::Calculations.longitude_degree_distance(30, options[:units] || :mi)
        dy = Geocoder::Calculations.latitude_degree_distance(options[:units] || :mi)

        # sin of 45 degrees = average x or y component of vector
        factor = Math.sin(Math::PI / 4)

        distance = "(#{dy} * ABS(#{lat_attr} - #{latitude}) * #{factor}) + " +
          "(#{dx} * ABS(#{lon_attr} - #{longitude}) * #{factor})"
        default_near_scope_options(latitude, longitude, radius, options).merge(
          :select => "#{options[:select] || '*'}, " +
            "#{distance} AS distance" +
            (bearing ? ", #{bearing} AS bearing" : ""),
          :order => distance
        )
      end

      ##
      # Options used for any near-like scope.
      #
      def default_near_scope_options(latitude, longitude, radius, options)
        lat_attr = geocoder_options[:latitude]
        lon_attr = geocoder_options[:longitude]
        b = Geocoder::Calculations.bounding_box([latitude, longitude], radius, options)
        conditions = \
          ["#{lat_attr} BETWEEN ? AND ? AND #{lon_attr} BETWEEN ? AND ?"] +
          [b[0], b[2], b[1], b[3]]
        if obj = options[:exclude]
          conditions[0] << " AND #{table_name}.id != ?"
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
    end

    ##
    # Look up coordinates and assign to +latitude+ and +longitude+ attributes
    # (or other as specified in +geocoded_by+). Returns coordinates (array).
    #
    def geocode
      do_lookup(false) do |o,rs|
        r = rs.first
        unless r.latitude.nil? or r.longitude.nil?
          o.send :write_attribute, self.class.geocoder_options[:latitude],  r.latitude
          o.send :write_attribute, self.class.geocoder_options[:longitude], r.longitude
        end
        r.coordinates
      end
    end

    alias_method :fetch_coordinates, :geocode

    ##
    # Look up address and assign to +address+ attribute (or other as specified
    # in +reverse_geocoded_by+). Returns address (string).
    #
    def reverse_geocode
      do_lookup(true) do |o,rs|
        r = rs.first
        unless r.address.nil?
          o.send :write_attribute, self.class.geocoder_options[:fetched_address], r.address
        end
        r.address
      end
    end

    alias_method :fetch_address, :reverse_geocode
  end
end
