require 'geocoder/results/base'

module Geocoder::Result
  class Ip2locationApi < Base

    def address(format = :full)
      "#{city_name} #{zip_code}, #{country_name}".sub(/^[ ,]*/, '')
    end

    def country_code
      country_code
    end

    def country_name
      country_name
    end

    def region_name
      region_name
    end

    def city_name
      city_name
    end

    def latitude
      latitude
    end

    def longitude
      longitude
    end

    def zip_code
      zip_code
    end

    def time_zone
      time_zone
    end

    def isp
      isp
    end

    def domain
      domain
    end

    def net_speed
      net_speed
    end

    def idd_code
      idd_code
    end

    def area_code
      area_code
    end

    def weather_station_code
      weather_station_code
    end

    def weather_station_name
      weather_station_name
    end

    def mcc
      mcc
    end

    def mnc
      mnc
    end

    def mobile_brand
      mobile_brand
    end

    def elevation
      elevation
    end

    def usage_type
      usage_type
    end

    def self.response_attributes
      %w[country_code country_name region_name city_name latitude longitude zip_code time_zone isp domain net_speed idd_code area_code weather_station_code weather_station_name mcc mnc mobile_brand elevation usage_type]
    end

    response_attributes.each do |attribute|
      define_method attribute do
        @data[attribute]
      end
    end

  end
end
