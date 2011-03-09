require 'geocoder/orms/base'
require 'geocoder/orms/active_record_legacy'

##
# Add geocoding functionality to any ActiveRecord object.
#
module Geocoder::Orm
  module ActiveRecord
    include Base
    include ActiveRecord::Legacy

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
        # Find all objects within a radius (in miles) of the given location
        # (address string). Location (the first argument) may be either a string
        # to geocode or an array of coordinates (<tt>[lat,long]</tt>).
        #
        scope :near, lambda{ |location, *args|
          latitude, longitude = location.is_a?(Array) ?
            location : Geocoder.coordinates(location)
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
        radius *= Geocoder::Calculations.km_in_mi if options[:units] == :km
        if ::ActiveRecord::Base.connection.adapter_name == "SQLite"
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
    end

    ##
    # Look up coordinates and assign to +latitude+ and +longitude+ attributes
    # (or other as specified in +geocoded_by+). Returns coordinates (array).
    #
    def geocode
      do_lookup(false) do |o,r|
        unless r.latitude.nil? or r.longitude.nil?
          o.send :write_attribute, self.class.geocoder_options[:latitude],  r.latitude
          o.send :write_attribute, self.class.geocoder_options[:longitude], r.longitude
        end
        r.coordinates
      end
    end

    #alias_method :fetch_coordinates, :geocode

    ##
    # Look up address and assign to +address+ attribute (or other as specified
    # in +reverse_geocoded_by+). Returns address (string).
    #
    def reverse_geocode
      do_lookup(true) do |o,r|
        unless r.address.nil?
          o.send :write_attribute, self.class.geocoder_options[:fetched_address], r.address
        end
        r.address
      end
    end

    #alias_method :fetch_address, :reverse_geocode
  end
end
