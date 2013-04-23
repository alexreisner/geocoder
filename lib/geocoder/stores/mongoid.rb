require 'geocoder/stores/base'
require 'geocoder/stores/mongo_base'

module Geocoder::Store
  module Mongoid
    include Base
    include MongoBase

    def self.included(base)
      MongoBase.included_by_model(base)
      base.class_eval do

        ##
        # Name of the attribute to use when determining whether two
        # records are the same record.
        #
        def self.primary_key
          "_id"
        end
      end
    end
  end
end
