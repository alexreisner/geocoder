require 'geocoder'

module Geocoder

  ##
  # Methods for invoking Geocoder in a model.
  #
  module Model
    module Base

      def geocoder_options
        if defined?(@geocoder_options)
          @geocoder_options
        elsif superclass.respond_to?(:geocoder_options)
          superclass.geocoder_options
        end
      end

      def geocoded_by
        fail
      end

      def reverse_geocoded_by
        fail
      end

      def geocoded_through(assoc_name)
        fail
      end
      
      private # ----------------------------------------------------------------

      def geocoder_init(options)
        unless @geocoder_options
          @geocoder_options = {}
          require "geocoder/stores/#{geocoder_file_name}"
          include Geocoder::Store.const_get(geocoder_module_name)
        end
        @geocoder_options.merge! options

        if through = @geocoder_options[:through]
          table_name                    = through.table_name
          lat_attr                      = @geocoder_options[:latitude]
          lon_attr                      = @geocoder_options[:longitude]
          @geocoder_options[:latitude]  = "#{table_name}.#{lat_attr}" unless lat_attr =~ /^#{table_name}\./
          @geocoder_options[:longitude] = "#{table_name}.#{lon_attr}" unless lon_attr =~ /^#{table_name}\./
        end
      end
    end
  end
end
