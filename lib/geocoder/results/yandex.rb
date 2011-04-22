require 'geocoder/results/base'

module Geocoder::Result
  class Yandex < Base

    def coordinates
      @data['GeoObject']['Point']['pos'].split(' ').reverse.map(&:to_f)
    end

    def address(format = :full)
      @data['GeoObject']['metaDataProperty']['GeocoderMetaData']['text']
    end

    def city
      address_details['Locality']['LocalityName']
    end

    def country
      address_details['CountryName']
    end

    def country_code
      address_details['CountryNameCode']
    end

    def state
      ""
    end

    def state_code
      ""
    end

    def postal_code
      ""
    end

    def premise_name
      address_details['Locality']['Premise']['PremiseName']
    end

    private # ----------------------------------------------------------------

    def address_details
      @data['GeoObject']['metaDataProperty']['GeocoderMetaData']['AddressDetails']['Country']
    end
  end
end
