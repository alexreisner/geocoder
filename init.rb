ActiveRecord::Base.class_eval do
  
  ##
  # Include the Geocoder module and set the method name which returns
  # the geo-search string.
  #
  def self.geocoded_by(method_name = :location)
    include Geocoder
    @geocoder_method_name = method_name
  end
end
