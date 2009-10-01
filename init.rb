ActiveRecord::Base.class_eval do
  
  ##
  # Include the Geocoder module and set attribute names.
  #
  def self.geocoded_by(method_name = :location, options = {})
    class_inheritable_reader :geocoder_options
    write_inheritable_attribute :geocoder_options, {
      :method_name => method_name,
      :latitude    => options[:latitude]  || :latitude,
      :longitude   => options[:longitude] || :longitude
    }
    include Geocoder
  end
end
