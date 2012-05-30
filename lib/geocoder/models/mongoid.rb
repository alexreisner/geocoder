require 'geocoder/models/base'
require 'geocoder/models/mongo_base'

module Geocoder
  module Model
    module Mongoid
      include Base
      include MongoBase

      def self.included(base); base.extend(self); end

      private # --------------------------------------------------------------

      def geocoder_file_name;   "mongoid"; end
      def geocoder_module_name; "Mongoid"; end

      def geocoder_init(options)
        super(options)
        if options[:skip_index] == false
          # index [[ geocoder_options[:coordinates], Mongo::GEO2D ]],
          #             :min => -180, :max => 180 # create 2d index
            
          index geocoder_options[:coordinates] => "2d" #Updated to work with new Mongoid 3.0.0rc
          # Refer to http://mongoid.org/en/mongoid/docs/upgrading.html
        end
      end
    end
  end
end
