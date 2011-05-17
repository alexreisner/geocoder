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


      private # ----------------------------------------------------------------

      def geocoder_init(options)
        unless @geocoder_options
          @geocoder_options = {}
          require "geocoder/stores/#{geocoder_file_name}"
          include eval("Geocoder::Store::" + geocoder_module_name)
        end
        @geocoder_options.merge! options
      end

      def geocoder_initialized?
        begin
          included_modules.include? eval("Geocoder::Store::" + geocoder_module_name)
        rescue NameError
          false
        end
      end
    end
  end
end
