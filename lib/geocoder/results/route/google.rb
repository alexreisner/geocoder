require 'geocoder/results/route/base'

module Geocoder::Result::Route
  class GooglePart
    def initialize(data)
      @data = data
    end
    
    # ----------------------------------------------------------------
    
    # indicates the total distance covered by this leg, as a field with the following elements
    def distance
      @data['distance']['value']
    end
    
    # ----------------------------------------------------------------
    
    # indicates the total duration of this leg, as a field with the following elements
    def duration
      @data['duration']['value']
    end
    
  end
  
  
  
  
  # ----------------------------------------------------------------
  # ----------------------------------------------------------------
  # ----------------------------------------------------------------
  
  
  
  
  class Google < Base
	  # contains an array which contains information about a part of the route, between two locations within the given route.
	  # A separate part will be present for each waypoint or destination specified. (A route with no waypoints will contain
	  # exactly one part within the parts array.) Each part consists of a series of steps.
    def parts
      @legs ||= @data['legs'].collect do |leg_data|
        GooglePart.new(leg_data)
      end
    end
    
    # ----------------------------------------------------------------
    
    # contains a short textual description for the route, suitable for naming and disambiguating the route from alternatives.
    def summary
      @data['summary']
    end

    # ----------------------------------------------------------------

    # contains the viewport bounding box of this route
    def bounds
    	@data['bounds']
    end
    
    
    # ----------------------------------------------------------------
    
    # return the bounds of the viewport of the route
    # [north_east.lattitude, north_east.longitude, south_west.longitude, south_west.longitude]
    def bounding_box
      north_east = @data['bounds']['northeast']
      south_west = @data['bounds']['southwest']
      
      [north_east['lat'], north_east['lng'], south_west['lat'], south_west['lng']]
    end
  end
end
