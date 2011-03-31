require 'geocoder/models/base'

module Geocoder
  module Model
    module Mongoid
      include Base

      def self.included(base); base.extend(self); end

      ##
      # Set attribute names and include the Geocoder module.
      #
      def geocoded_by(address_attr, options = {}, &block)
        geocoder_init(
          :geocode       => true,
          :user_address  => address_attr,
          :coordinates   => options[:coordinates] || :coordinates,
          :geocode_block => block
        )
      end

      ##
      # Set attribute names and include the Geocoder module.
      #
      def reverse_geocoded_by(coordinates_attr, options = {}, &block)
        geocoder_init(
          :reverse_geocode => true,
          :fetched_address => options[:address] || :address,
          :coordinates     => coordinates_attr,
          :reverse_block   => block
        )
      end


      private # --------------------------------------------------------------

      def geocoder_file_name;   "mongoid"; end
      def geocoder_module_name; "Mongoid"; end

      def geocoder_init(options)
        super(options)
        index [[ geocoder_options[:coordinates], Mongo::GEO2D ]],
          :min => -180, :max => 180 # create 2d index
      end
    end
  end
end
