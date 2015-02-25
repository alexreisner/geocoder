# -*- coding: utf-8 -*-
require 'geocoder/stores/base'

##
# Add geocoding functionality to any DataMapper::Resource object.
#
module Geocoder::Store
  module DataMapper
    include Base

    ##
    # Implementation of 'included' hook method.
    #
    def self.included(base)
      base.class_eval do
        # DataMapper scope equaliance. See: http://datamapper.org/docs/find.html
        def geocoded
          all(:conditions => ["latitude IS NOT NULL AND longitude IS NOT NULL"])
        end

        def not_geocoded
          all(:conditions => ["latitude IS NULL OR longitude IS NULL"])
        end
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

  end
end
