require 'geocoder/route_results/base'

module Geocoder::RouteResult
  class GoogleApiV3RoutePart
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
  
  class GoogleApiV3 < Base
	  # contains an array which contains information about a part of the route, between two locations within the given route.
	  # A separate part will be present for each waypoint or destination specified. (A route with no waypoints will contain
	  # exactly one part within the parts array.) Each part consists of a series of steps.
    def parts
      @legs ||= @data['legs'].collect do |leg_data|
        GoogleApiV3RoutePart.new(leg_data)
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
  end
end
