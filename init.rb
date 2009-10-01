ActiveRecord::Base.class_eval do
  
  ##
  # Include the Geocoder module and set the method name which returns
  # the geo-search string.
  #
  def self.geocoded_by(method_name = :location, options = {})
    include Geocoder
    @geocoder_method_name    = method_name
    @geocoder_latitude_attr  = options[:latitude]  || :latitude
    @geocoder_longitude_attr = options[:longitude] || :longitude
  end
end
