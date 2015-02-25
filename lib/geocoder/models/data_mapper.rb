require 'geocoder/models/base'

module Geocoder
  module Model
    module DataMapper
      include Base

      def self.included(base); base.extend(self); end

      ##
      # Set attribute names and include the Geocoder module.
      #
      def geocoded_by(address_attr, options = {}, &block)
        geocoder_init(
          :geocode       => true,
          :user_address  => address_attr,
          :latitude      => options[:latitude]  || :latitude,
          :longitude     => options[:longitude] || :longitude,
          :geocode_block => block,
          :units         => options[:units],
          :method        => options[:method],
          :lookup        => options[:lookup],
          :language      => options[:language]
        )
      end

      ##
      # Set attribute names and include the Geocoder module.
      #
      def reverse_geocoded_by(latitude_attr, longitude_attr, options = {}, &block)
        geocoder_init(
          :reverse_geocode => true,
          :fetched_address => options[:address] || :address,
          :latitude        => latitude_attr,
          :longitude       => longitude_attr,
          :reverse_block   => block,
          :units           => options[:units],
          :method          => options[:method],
          :lookup          => options[:lookup],
          :language        => options[:language]
        )
      end

      private # ----------------------------------------------------------------

      def geocoder_init(options)
        unless geocoder_initialized?
          @geocoder_options = { }
          require "geocoder/stores/#{geocoder_file_name}"
          include Geocoder::Store.const_get(geocoder_module_name)
        end
        @geocoder_options.merge! options
      end

      def geocoder_initialized?
        included_modules.include? Geocoder::Store.const_get(geocoder_module_name)
      rescue NameError
        false
      end

      def geocoder_file_name;   "data_mapper"; end
      def geocoder_module_name; "DataMapper"; end
    end
  end
end
