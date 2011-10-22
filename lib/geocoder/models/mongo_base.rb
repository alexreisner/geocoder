require 'geocoder'

module Geocoder

  ##
  # Methods for invoking Geocoder in a model.
  #
  module Model
    module MongoBase

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

      private # ----------------------------------------------------------------

      def geocoder_init(options)
        unless geocoder_initialized?
          @geocoder_options = {}
          require "geocoder/stores/#{geocoder_file_name}"
          include Geocoder::Store.const_get(geocoder_module_name)
        end
        @geocoder_options.merge! options
      end

      def geocoder_initialized?
        begin
          included_modules.include? Geocoder::Store.const_get(geocoder_module_name)
        rescue NameError
          false
        end
      end
    end
  end
end
