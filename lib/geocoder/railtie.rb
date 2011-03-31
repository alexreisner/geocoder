require 'geocoder'
require 'geocoder/models/active_record'

module Geocoder
  if defined? Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie
      initializer 'geocoder.insert_into_active_record' do
        ActiveSupport.on_load :active_record do
          Geocoder::Railtie.insert
        end
      end
      rake_tasks do
        load "tasks/geocoder.rake"
      end
    end
  end

  class Railtie
    def self.insert
      if defined?(::ActiveRecord)
        ::ActiveRecord::Base.extend(Model::ActiveRecord)
      end
    end
  end
end
