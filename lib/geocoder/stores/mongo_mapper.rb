require "#{File.dirname(__FILE__)}/base"
require "#{File.dirname(__FILE__)}/mongo_base"

module Geocoder::Store
  module MongoMapper
    include Base
    include MongoBase

    def self.included(base)
      MongoBase.included_by_model(base)
    end
  end
end
