require 'geocoder/results/base'

module Geocoder::Result
  class GeocoderCa < Base

    def coordinates
      [@data['latt'].to_f, @data['longt'].to_f]
    end

    def address(format = :full)
      "#{street_address}, #{city}, #{state} #{postal_code}, #{country}"
    end

    def street_address
      "#{@data['stnumber']} #{@data['staddress']}"
    end

    def city
      @data['city']
    end

    def state
      @data['prov']
    end

    alias_method :province, :state

    def postal_code
      @data['postal']
    end

    def country
      country_code == 'CA' ? 'Canada' : 'United States'
    end

    def country_code
      prov = @data['prov']
      return nil if prov.nil? || prov == ""
      canadian_province_abbreviations.include?(@data['prov']) ? "CA" : "US"
    end

    def canadian_province_abbreviations
      %w[ON QC NS NB MB BC PE SK AB NL]
    end

    def self.response_attributes
      %w[latt longt inlatt inlongt betweenRoad1 betweenRoad2 distance
        stnumber staddress city prov postal
        NearRoad NearRoadDistance intersection major_intersection]
    end

    response_attributes.each do |a|
      define_method a do
        @data[a]
      end
    end
  end
end
