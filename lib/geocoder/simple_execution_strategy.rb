module Geocoder
  class SimpleExecutionStrategy
    def execute(lookup, text, options)
      lookup.search(text, options)
    end
  end
end
