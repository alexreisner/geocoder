require 'geocoder/lookups/base'

module Geocoder::Lookup
  class Empty < Base
    def results(query)
      []
    end
  end
end
