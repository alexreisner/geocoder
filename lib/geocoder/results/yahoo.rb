require 'geocoder/results/base'

module Geocoder::Result
  class Yahoo < Base

    def coordinates
      [latitude.to_f, longitude.to_f]
    end

    def address(format = :full)
      (1..3).to_a.map{ |i| @data["line#{i}"] }.reject{ |i| i.nil? or i == "" }.join(", ")
    end

    def self.yahoo_attributes
      %w[quality latitude longitude offsetlat offsetlon radius boundingbox name
        line1 line2 line3 line4 cross house street xstreet unittype unit postal
        neighborhood city county state country countrycode statecode countycode
        level0 level1 level2 level3 level4 level0code level1code level2code
        timezone areacode uzip hash woeid woetype]
    end

    yahoo_attributes.each do |a|
      define_method a do
        @data[a]
      end
    end
  end
end
