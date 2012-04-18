require 'geocoder/route_results/base'

module Geocoder::RouteResult
  class GoogleApiV3RoutePart
    def initialize(data)
      @data = data
    end
    
    # ----------------------------------------------------------------
    
    def distance
      @data['distance']['value']
    end
    
    # ----------------------------------------------------------------
    
    def duration
      @data['duration']['value']
    end
  end
  
  # ----------------------------------------------------------------
  # ----------------------------------------------------------------
  
  class GoogleApiV3 < Base
    def parts
      @legs ||= @data['legs'].collect do |leg_data|
        GoogleApiV3RoutePart.new(leg_data)
      end
    end
    
    # ----------------------------------------------------------------
    
    def summary
      @data['summary']
    end
  end
end
