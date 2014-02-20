require 'geocoder/results/base'

module Geocoder::Result
  class Yandex < Base

    def coordinates
      @data['GeoObject']['Point']['pos'].split(' ').reverse.map(&:to_f)
    end

    def address(format = :full)
      @data['GeoObject']['metaDataProperty']['GeocoderMetaData']['text'] rescue ""
    end

    def city
      address_details['AdministrativeArea']["Locality"]["LocalityName"] rescue ""
    end

    def country
      address_details['CountryName'] rescue ""
    end

    def street
      address_details['AdministrativeArea']['SubAdministrativeArea']['Locality']['Thoroughfare']['ThoroughfareName'] rescue "" #Return street name or empty string
    end

    def house
      address_details['AdministrativeArea']['SubAdministrativeArea']['Locality']['Thoroughfare']['Premise']['PremiseNumber'] rescue "" #House number or empty string
    end

    def country_code
      address_details['CountryNameCode'] rescue ""
    end

    def state
      address_details['AdministrativeArea']['AdministrativeAreaName'] rescue ""
    end

    def sub_state
      address_details['AdministrativeArea']['SubAdministrativeArea']['SubAdministrativeAreaName'] rescue ""
    end

    def state_code
      ""
    end

    def postal_code
      ""
    end

    def premise_name
      address_details['Locality']['Premise']['PremiseName'] rescue ""
    end

    def kind
      @data['GeoObject']['metaDataProperty']['GeocoderMetaData']['kind']
    end

    def precision
      @data['GeoObject']['metaDataProperty']['GeocoderMetaData']['precision']
    end

    private # ----------------------------------------------------------------

    def address_details
      @data['GeoObject']['metaDataProperty']['GeocoderMetaData']['AddressDetails']['Country']
    end

    def sub_state_city
      if !sub_state.empty? and address_details['AdministrativeArea']['SubAdministrativeArea'].has_key? 'Locality'
        address_details['AdministrativeArea']['SubAdministrativeArea']['Locality']['LocalityName'] || ""
      else
        ""
      end
    end
  end
end
