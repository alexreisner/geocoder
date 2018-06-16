require 'geocoder/models/base'
require 'geocoder/models/active_record'

module Geocoder
  module Model
    module Sequel
      include Base
      include ActiveRecord

      private # --------------------------------------------------------------

      def geocoder_file_name;   "sequel"; end
      def geocoder_module_name; "Sequel"; end
    end
  end
end
