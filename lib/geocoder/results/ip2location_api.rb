require 'geocoder/results/base'

module Geocoder::Result
  class Ip2locationApi < Base

    def address(format = :full)
      "#{city_name} #{zip_code}, #{country_name}".sub(/^[ ,]*/, '')
    end

    def country_code
      @data['country_code']
    end

    def country_name
      @data['country_name']
    end

    def region_name
      @data['region_name']
    end

    def city_name
      @data['city_name']
    end

    def latitude
      @data['latitude']
    end

    def longitude
      @data['longitude']
    end

    def zip_code
      @data['zip_code']
    end

    def time_zone
      @data['time_zone']
    end

    def isp
      @data['isp']
    end

    def domain
      @data['domain']
    end

    def net_speed
      @data['net_speed']
    end

    def idd_code
      @data['idd_code']
    end

    def area_code
      @data['area_code']
    end

    def weather_station_code
      @data['weather_station_code']
    end

    def weather_station_name
      @data['weather_station_name']
    end

    def mcc
      @data['mcc']
    end

    def mnc
      @data['mnc']
    end

    def mobile_brand
      @data['mobile_brand']
    end

    def elevation
      @data['elevation']
    end

    def usage_type
      @data['usage_type']
    end

  end
end
