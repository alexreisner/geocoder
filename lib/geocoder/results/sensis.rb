require 'geocoder/lookups/base'

module Geocoder::Result
  class Sensis < Base

    def coordinates
      ['lat', 'lon'].map{ |i| @data['geometry']['centre'][i] }
    end

    def precision
      granularity
    end

    def granularity
      @data["granularity"]
    end
  end

end