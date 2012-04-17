require 'geocoder/direction_results/base'

module Geocoder::DirectionResult
  class GoogleApiV3Leg
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
    def legs
      @legs ||= @data['legs'].collect do |leg_data|
        GoogleApiV3Leg.new(leg_data)
      end
    end
    
    # ----------------------------------------------------------------
    
    def summary
      @data['summary']
    end
  end
end
