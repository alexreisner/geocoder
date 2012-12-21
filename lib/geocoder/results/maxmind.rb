require 'geocoder/results/base'

module Geocoder::Result
  class Maxmind < Base

    def address(format = :full)
      s = state_code.to_s == "" ? "" : ", #{state_code}"
      "#{city}#{s} #{postal_code}, #{country_code}".sub(/^[ ,]*/, "")
    end

    def country_code
      @data[0]
    end

    def state_code
      @data[1]
    end

    def city
      @data[2]
    end

    def postal_code
      @data[3]
    end

    def coordinates
      [@data[4].to_f, @data[5].to_f]
    end

    def metrocode
      @data[6]
    end

    def area_code
      @data[7]
    end

    def isp
      @data[8][1,@data[8].length-2]
    end

    def organization
      @data[9][1,@data[9].length-2]
    end

    def country #not given by MaxMind
      country_code
    end

    def state #not given by MaxMind
      state_code
    end
  end
end
