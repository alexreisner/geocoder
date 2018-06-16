# -*- coding: utf-8 -*-
require 'geocoder/sql'
require 'geocoder/stores/base'

##
# Add geocoding functionality to any Sequel model.
#
module Geocoder::Store
  module Sequel
    #the again could be cleaned up alot if we reorganised active record
    module DatasetMethods
      def geocoder_options
        model.geocoder_options
      end

      def geocoded
        where{~("#{table_name}.#{geocoder_options[:latitude]}" == nil) &
              ~("#{table_name}.#{geocoder_options[:longitude]}" == nil)}
      end

      def not_geocoded
        where{("#{table_name}.#{geocoder_options[:latitude]}" == nil) |
              ("#{table_name}.#{geocoder_options[:longitude]}" == nil)}
      end

      def not_reverse_geocoded
        where{("#{table_name}.#{geocoder_options[:fetched_address]}" == nil)}
      end

      ##
      # Find all objects within a radius of the given location.
      # Location may be either a string to geocode or an array of
      # coordinates (<tt>[lat,lon]</tt>). Also takes an options hash
      # (see Geocoder::Store::ActiveRecord::ClassMethods.near_scope_options
      # for details).
      #
      def near(location, *args)
        latitude, longitude = Geocoder::Calculations.extract_coordinates(location)
        if Geocoder::Calculations.coordinates_present?(latitude, longitude)
          options = near_scope_options(latitude, longitude, *args)
          result = options[:select]
          options[:conditions].each do |condition|
            result = result.where(condition)
          end
          result.order(options[:order])
        else
          # If no lat/lon given we don't want any results, but we still
          # need distance and bearing columns so you can add, for example:
          # .order("distance")
          select_clause(nil, null_value, null_value).where(::Sequel.lit(false_condition))
        end
      end

      ##
      # Find all objects within the area of a given bounding box.
      # Bounds must be an array of locations specifying the southwest
      # corner followed by the northeast corner of the box
      # (<tt>[[sw_lat, sw_lon], [ne_lat, ne_lon]]</tt>).
      #
      def within_bounding_box(bounds)
        sw_lat, sw_lng, ne_lat, ne_lng = bounds.flatten if bounds
        if sw_lat && sw_lng && ne_lat && ne_lng
          where(::Sequel.lit(Geocoder::Sql.within_bounding_box(
            sw_lat, sw_lng, ne_lat, ne_lng,
            full_column_name(geocoder_options[:latitude]),
            full_column_name(geocoder_options[:longitude])
          )))
        else
          select_clause(nil, null_value, null_value).where(::Sequel.lit(false_condition))
        end
      end


      def distance_from_sql(location, *args)
        latitude, longitude = Geocoder::Calculations.extract_coordinates(location)
        if Geocoder::Calculations.coordinates_present?(latitude, longitude)
          distance_sql(latitude, longitude, *args)
        end
      end



      # private # ----------------------------------------------------------------
      # THIS SHOULD BE PRIVATE, BUT IS CALLED IN TESTS.... GRRR

      ##
      # Get options hash suitable for passing to ActiveRecord.find to get
      # records within a radius (in kilometers) of the given point.
      # Options hash may include:
      #
      # * +:units+   - <tt>:mi</tt> or <tt>:km</tt>; to be used.
      #   for interpreting radius as well as the +distance+ attribute which
      #   is added to each found nearby object.
      #   Use Geocoder.configure[:units] to configure default units.
      # * +:bearing+ - <tt>:linear</tt> or <tt>:spherical</tt>.
      #   the method to be used for calculating the bearing (direction)
      #   between the given point and each found nearby point;
      #   set to false for no bearing calculation. Use
      #   Geocoder.configure[:distances] to configure default calculation method.
      # * +:select+          - string with the SELECT SQL fragment (e.g. “id, name”)
      # * +:select_distance+ - whether to include the distance alias in the
      #                        SELECT SQL fragment (e.g. <formula> AS distance)
      # * +:select_bearing+  - like +:select_distance+ but for bearing.
      # * +:order+           - column(s) for ORDER BY SQL clause; default is distance;
      #                        set to false or nil to omit the ORDER BY clause
      # * +:exclude+         - an object to exclude (used by the +nearbys+ method)
      # * +:distance_column+ - used to set the column name of the calculated distance.
      # * +:bearing_column+  - used to set the column name of the calculated bearing.
      # * +:min_radius+      - the value to use as the minimum radius.
      #                        ignored if database is sqlite.
      #                        default is 0.0
      #
      def near_scope_options(latitude, longitude, radius = 20, options = {})
        if options[:units]
          options[:units] = options[:units].to_sym
        end
        latitude_attribute = options[:latitude] || geocoder_options[:latitude]
        longitude_attribute = options[:longitude] || geocoder_options[:longitude]
        options[:units] ||= (geocoder_options[:units] || Geocoder.config.units)
        select_distance = options.fetch(:select_distance)  { true }
        options[:order] = "" if !select_distance && !options.include?(:order)
        select_bearing = options.fetch(:select_bearing) { true }
        bearing = bearing_sql(latitude, longitude, options)
        distance = distance_sql(latitude, longitude, options)
        distance_column = options.fetch(:distance_column) { 'distance' }
        bearing_column = options.fetch(:bearing_column)  { 'bearing' }

        # If radius is a DB column name, bounding box should include
        # all rows within the maximum radius appearing in that column.
        # Note: performance is dependent on variability of radii.
        bb_radius = radius.is_a?(Symbol) ? max(radius) : radius
        b = Geocoder::Calculations.bounding_box([latitude, longitude], bb_radius, options)
        args = b + [
          full_column_name(latitude_attribute),
          full_column_name(longitude_attribute)
        ]
        conditions = [::Sequel.lit(Geocoder::Sql.within_bounding_box(*args))]

        unless using_unextended_sqlite?
          min_radius = options.fetch(:min_radius, 0).to_f
          # if radius is a DB column name,
          # find rows between min_radius and value in column
          if radius.is_a?(Symbol)
            conditions << ::Sequel.lit("#{distance} BETWEEN ? AND #{radius}", min_radius)
          else
            conditions << ::Sequel.lit("#{distance} BETWEEN ? AND ?", min_radius, radius)
          end
          conditions
        end
        {
          :select => select_clause(options[:select],
                                   select_distance ? distance : nil,
                                   select_bearing ? bearing : nil,
                                   distance_column,
                                   bearing_column),
          :conditions => add_exclude_condition(conditions, options[:exclude]),
          :order => options.include?(:order) ? ::Sequel.lit(options[:order]) : ::Sequel.asc(distance_column.to_sym)
        }
      end

      private # ----------------------------------------------------------------

      ##
      # SQL for calculating distance based on the current database's
      # capabilities (trig functions?).
      #
      def distance_sql(latitude, longitude, options = {})
        method_prefix = using_unextended_sqlite? ? "approx" : "full"
        Geocoder::Sql.send(
          method_prefix + "_distance",
          latitude, longitude,
          full_column_name(options[:latitude] || geocoder_options[:latitude]),
          full_column_name(options[:longitude]|| geocoder_options[:longitude]),
          options
        )
      end

      ##
      # SQL for calculating bearing based on the current database's
      # capabilities (trig functions?).
      #
      def bearing_sql(latitude, longitude, options = {})
        if !options.include?(:bearing)
          options[:bearing] = Geocoder.config.distances
        end
        if options[:bearing]
          method_prefix = using_unextended_sqlite? ? "approx" : "full"
          Geocoder::Sql.send(
            method_prefix + "_bearing",
            latitude, longitude,
            full_column_name(options[:latitude] || geocoder_options[:latitude]),
            full_column_name(options[:longitude]|| geocoder_options[:longitude]),
            options
          )
        end
      end

      ##
      # Generate the SELECT clause.
      #
      def select_clause(columns, distance = nil, bearing = nil, distance_column = 'distance', bearing_column = 'bearing')
        if columns == :id_only
          return select(full_column_name(model.primary_key))
        end

        clause = (columns && columns != :geo_only) ? select(columns) : self

        if distance
          clause = clause.select_append(::Sequel.lit(distance).as(distance_column))
        end

        if bearing
          clause = clause.select_append(::Sequel.lit(bearing).as(bearing_column))
        end

        clause
      end

      ##
      # Adds a condition to exclude a given object by ID.
      # Expects conditions as an array or string. Returns array.
      #
      def add_exclude_condition(conditions, exclude_object)
        return conditions unless exclude_object

        conditions << ::Sequel.negate(full_column_name(model.primary_key) => exclude_object.id)
      end

      def using_unextended_sqlite?
        using_sqlite? && !using_sqlite_with_extensions?
      end

      def using_sqlite?
        DB.database_type == :sqlite
      end

      def using_sqlite_with_extensions?
        using_sqlite? &&
          defined?(::SqliteExt) &&
          %W(MOD POWER SQRT PI SIN COS ASIN ATAN2).all?{ |fn_name|
            connection.raw_connection.function_created?(fn_name)
          }
      end

      def using_postgres?
        DB.database_type == :postgres
      end

      ##
      # Use OID type when running in PosgreSQL
      #
      def null_value
        using_postgres? ? 'NULL::text' : 'NULL'
      end

      ##
      # Value which can be passed to where() to produce no results.
      #
      def false_condition
        using_unextended_sqlite? ? 0 : "false"
      end

      ##
      # Prepend table name if column name doesn't already contain one.
      #
      def full_column_name(column)
        column = column.to_s
        column.include?(".") ? column : [model.table_name, column].join(".")
      end
    end

    module ClassMethods
      include Geocoder::Model::Sequel

      ::Sequel::Plugins.def_dataset_methods(self, :near_scope_options)
    end

    module InstanceMethods
      include Base

      ##
      # Get nearby geocoded objects.
      # Takes the same options hash as the near class method (scope).
      # Returns nil if the object is not geocoded.
      #
      def nearbys(radius = 20, options = {})
        return nil unless geocoded?
        options.merge!(:exclude => self) unless send(self.class.primary_key).nil?
        self.class.near(self, radius, options)
      end

      ##
      # Look up coordinates and assign to +latitude+ and +longitude+ attributes
      # (or other as specified in +geocoded_by+). Returns coordinates (array).
      #
      def geocode
        do_lookup(false) do |o,rs|
          if r = rs.first
            unless r.latitude.nil? or r.longitude.nil?
              o.__send__  "#{self.class.geocoder_options[:latitude]}=",  r.latitude
              o.__send__  "#{self.class.geocoder_options[:longitude]}=", r.longitude
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
              o.__send__ "#{self.class.geocoder_options[:fetched_address]}=", r.address
            end
            r.address
          end
        end
      end

      alias_method :fetch_address, :reverse_geocode
    end
  end
end
