require "geocoder/calculations"
require "geocoder/lookup"
require "geocoder/active_record"

##
# Add geocoded_by method to ActiveRecord::Base so Geocoder is accessible.
#
ActiveRecord::Base.class_eval do

  ##
  # Set attribute names and include the Geocoder module.
  #
  def self.geocoded_by(address_attr, options = {})
    class_inheritable_reader :geocoder_options
    write_inheritable_attribute :geocoder_options, {
      :address_attr => address_attr,
      :latitude     => options[:latitude]  || :latitude,
      :longitude    => options[:longitude] || :longitude
    }
    include Geocoder::ActiveRecord
  end
end
