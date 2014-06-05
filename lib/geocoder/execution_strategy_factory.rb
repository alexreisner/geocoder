require "geocoder/simple_execution_strategy"

module Geocoder
  class ExecutionStrategyFactory
    def strategy
      if Configuration.fallback_config_valid?
        FallbackExecutionStrategy.new
      else
        SimpleExecutionStrategy.new
      end
    end
  end
end
