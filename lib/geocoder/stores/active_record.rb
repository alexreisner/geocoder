# -*- coding: utf-8 -*-
require 'geocoder/sql'
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
          where("#{geocoder_options[:latitude]} IS NOT NULL " +
            "AND #{geocoder_options[:longitude]} IS NOT NULL")
        }

        # scope: not-geocoded objects
        scope :not_geocoded, lambda {
          where("#{geocoder_options[:latitude]} IS NULL " +
            "OR #{geocoder_options[:longitude]} IS NULL")
        }

        ##
        # Find all objects within a radius of the given location.
        # Location may be either a string to geocode or an array of
        # coordinates (<tt>[lat,lon]</tt>). Also takes an options hash
        # (see Geocoder::Store::ActiveRecord::ClassMethods.near_scope_options
        # for details).
        #
        scope :near, lambda{ |location, *args|
          latitude, longitude = Geocoder::Calculations.extract_coordinates(location)
          if Geocoder::Calculations.coordinates_present?(latitude, longitude)
            options = near_scope_options(latitude, longitude, *args)
            s = where(options[:conditions]).order(options[:order])
            s.select! options[:select] unless options[:select].nil?
            s
          else
            # If no lat/lon given we don't want any results, but we still
            # need distance and bearing columns so you can add, for example:
            # .order("distance")
            select(select_clause(nil, "NULL", "NULL")).where(false_condition)
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
          if sw_lat && sw_lng && ne_lat && ne_lng
            where(Geocoder::Sql.within_bounding_box(
              sw_lat, sw_lng, ne_lat, ne_lng,
              full_column_name(geocoder_options[:latitude]),
              full_column_name(geocoder_options[:longitude])
            ))
          else
            select(select_clause(nil, "NULL", "NULL")).where(false_condition)
          end
        }
      end
    end

    ##
    # Methods which will be class methods of the including class.
    #
    module ClassMethods

      def distance_from_sql(location, *args)
        latitude, longitude = Geocoder::Calculations.extract_coordinates(location)
        if Geocoder::Calculations.coordinates_present?(latitude, longitude)
          distance_sql(latitude, longitude, *args)
        end
      end

      private # ----------------------------------------------------------------

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
      # * +:order_by_without_select+ - filter and order records by this column
      #                        but query distance and bearing for every records.
      #                        Currently only :distance is support as option
      #
      def near_scope_options(latitude, longitude, radius = 20, options = {})
        if options[:units]
          options[:units] = options[:units].to_sym
        end
        options[:units] ||= (geocoder_options[:units] || Geocoder.config.units)
        select_distance = options.fetch(:select_distance, true)
        options[:order] = "" if !select_distance && !options.include?(:order)
        select_bearing = options.fetch(:select_bearing, true)
        bearing = bearing_sql(latitude, longitude, options)
        distance = distance_sql(latitude, longitude, options)
        distance_column = options.fetch(:distance_column, 'distance')
        bearing_column = options.fetch(:bearing_column, 'bearing')

        b = Geocoder::Calculations.bounding_box([latitude, longitude], radius, options)
        args = b + [
          full_column_name(geocoder_options[:latitude]),
          full_column_name(geocoder_options[:longitude])
        ]
        bounding_box_conditions = Geocoder::Sql.within_bounding_box(*args)

        if using_sqlite?
          conditions = bounding_box_conditions
        else
          min_radius = options.fetch(:min_radius, 0).to_f
          conditions = [bounding_box_conditions + " AND (#{distance}) BETWEEN ? AND ?", min_radius, radius]
        end
        case options[:order_by_without_select]
          when :distance
            options[:order] = "#{distance} ASC"
          when nil, ''
          else
            raise ArgumentError.new "Unknown order_by_without_select opion value \"#{options[:order_without_select]}\""
        end

        {
          :select => (select_clause(options[:select],
                                   select_distance ? distance : nil,
                                   select_bearing ? bearing : nil,
                                   distance_column,
                                   bearing_column) unless options[:order_by_without_select].present?),
          :conditions => add_exclude_condition(conditions, options[:exclude]),
          :order => options.include?(:order) ? options[:order] : "#{distance_column} ASC"
        }
      end

      ##
      # SQL for calculating distance based on the current database's
      # capabilities (trig functions?).
      #
      def distance_sql(latitude, longitude, options = {})
        method_prefix = using_sqlite? ? "approx" : "full"
        Geocoder::Sql.send(
          method_prefix + "_distance",
          latitude, longitude,
          full_column_name(geocoder_options[:latitude]),
          full_column_name(geocoder_options[:longitude]),
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
          method_prefix = using_sqlite? ? "approx" : "full"
          Geocoder::Sql.send(
            method_prefix + "_bearing",
            latitude, longitude,
            full_column_name(geocoder_options[:latitude]),
            full_column_name(geocoder_options[:longitude]),
            options
          )
        end
      end

      ##
      # Generate the SELECT clause.
      #
      def select_clause(columns, distance = nil, bearing = nil, distance_column = 'distance', bearing_column = 'bearing')
        if columns == :id_only
          return full_column_name(primary_key)
        elsif columns == :geo_only
          clause = ""
        else
          clause = (columns || full_column_name("*"))
        end
        if distance
          clause += ", " unless clause.empty?
          if using_postgresql?
            clause += "'#{distance}'::character(255) AS #{distance_column}"
          else
            clause += "#{distance} AS #{distance_column}"
          end
        end
        if bearing
          clause += ", " unless clause.empty?
          if using_postgresql?
            clause += "'#{bearing}'::character(255) AS #{bearing_column}"
          else
            clause += "#{bearing} AS #{bearing_column}"
          end
        end
        clause
      end

      ##
      # Adds a condition to exclude a given object by ID.
      # Expects conditions as an array or string. Returns array.
      #
      def add_exclude_condition(conditions, exclude)
        conditions = [conditions] if conditions.is_a?(String)
        if exclude
          conditions[0] << " AND #{full_column_name(primary_key)} != ?"
          conditions << exclude.id
        end
        conditions
      end

      def using_sqlite?
        connection.adapter_name.match(/sqlite/i)
      end

      def using_postgresql?
        connection.adapter_name.match(/postgres/i)
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
