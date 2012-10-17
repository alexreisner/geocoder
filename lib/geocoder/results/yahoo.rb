require 'geocoder/results/base'

module Geocoder::Result
  class Yahoo < Base

    def address(format = :full)
      (1..4).to_a.map{ |i| @data["line#{i}"] }.reject{ |i| i.nil? or i == "" }.join(", ")
    end

    def city
      @data['city']
    end

    def state
      @data['state']
    end

    def state_code
      @data['statecode']
    end

    def country
      @data['country']
    end

    def country_code
      @data['countrycode']
    end

    def postal_code
      @data['postal']
    end

    def address_hash
      @data['hash']
    end

    def self.response_attributes
      %w[quality offsetlat offsetlon radius boundingbox name
        line1 line2 line3 line4 cross house street xstreet unittype unit
        city state statecode country countrycode postal
        neighborhood county countycode
        level0 level1 level2 level3 level4 level0code level1code level2code
        timezone areacode uzip hash woeid woetype]
    end

    response_attributes.each do |a|
      unless method_defined?(a)
        define_method a do
          @data[a]
        end
      end
    end
  end
end
