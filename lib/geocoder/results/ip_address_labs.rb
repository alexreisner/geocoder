require 'geocoder/results/base'

module Geocoder::Result
  class IpAddressLabs < Base

    def coordinates
      [ @data["latitude"], @data["longitude"] ]
    end

    def continent_code
      @data["continent_code"]
    end

    def continent_name
      @data["continent_name"]
    end

    def country_code_iso3166alpha2
      @data["country_code_iso3166alpha2"]
    end

    def country_code_iso3166alpha3
      @data["country_code_iso3166alpha3"]
    end

    def country_code_iso3166numeric
      @data["country_code_iso3166numeric"]
    end

    def country_code_fips10_4
      @data["country_code_fips10-4"]
    end

    def country_name
      @data["country_name"]
    end

    def region_code
      @data["region_code"]
    end

    def region_name
      @data["region_name"]
    end

    def city
      @data["city"]
    end

    def postal_code
      @data["postal_code"]
    end

    def metro_code
      @data["metro_code"]
    end

    def area_code
      @data["area_code"]
    end

    def latitude
      @data["latitude"]
    end

    def longitude
      @data["longitude"]
    end

    def isp
      @data["isp"]
    end

    def organization
      @data["organization"]
    end
  end
end
