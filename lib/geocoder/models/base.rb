require 'geocoder'

module Geocoder

  ##
  # Methods for invoking Geocoder in a model.
  #
  module Model
    module Base

      def geocoder_options
        @geocoder_options
      end

      def geocoded_by
        fail
      end

      def reverse_geocoded_by
        fail
      end


      private # ----------------------------------------------------------------

      def geocoder_init(options)
        unless geocoder_initialized?
          @geocoder_options = {}
          require "geocoder/orms/#{geocoder_file_name}"
          include eval("Geocoder::Orm::" + geocoder_module_name)
        end
        @geocoder_options.merge! options
      end

      def geocoder_initialized?
        begin
          included_modules.include? eval("Geocoder::Orm::" + geocoder_module_name)
        rescue NameError
          false
        end
      end
    end
  end
end
