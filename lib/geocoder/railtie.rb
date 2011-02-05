require 'geocoder'

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

      return unless defined?(::ActiveRecord)

      ##
      # Add methods to ActiveRecord::Base so Geocoder is accessible by models.
      #
      ::ActiveRecord::Base.class_eval do

        ##
        # Set attribute names and include the Geocoder module.
        #
        def self.geocoded_by(address_attr, options = {})
          _geocoder_init(
            :user_address => address_attr,
            :latitude  => options[:latitude]  || :latitude,
            :longitude => options[:longitude] || :longitude
          )
        end

        ##
        # Set attribute names and include the Geocoder module.
        #
        def self.reverse_geocoded_by(latitude_attr, longitude_attr, options = {})
          _geocoder_init(
            :fetched_address => options[:address] || :address,
            :latitude  => latitude_attr,
            :longitude => longitude_attr
          )
        end

        def self._geocoder_init(options)
          unless _geocoder_initialized?
            class_inheritable_reader :geocoder_options
            class_inheritable_hash_writer :geocoder_options
          end
          self.geocoder_options = options
          unless _geocoder_initialized?
            include Geocoder::ActiveRecord
          end
        end

        def self._geocoder_initialized?
          included_modules.include? Geocoder::ActiveRecord
        end
      end

    end
  end
end
