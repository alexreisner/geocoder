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
      if state.empty?
        address_details['Locality']['LocalityName']
      elsif sub_state.empty?
        address_details['AdministrativeArea']['Locality']['LocalityName']
      elsif not sub_state_city.empty?
        sub_state_city
      else
        ""
      end
    end

    def country
      address_details['CountryName']
    end

    def country_code
      address_details['CountryNameCode']
    end

    def state
      if address_details['AdministrativeArea']
        address_details['AdministrativeArea']['AdministrativeAreaName']
      else
        ""
      end
    end

    def sub_state
      if !state.empty? and address_details['AdministrativeArea']['SubAdministrativeArea']
        address_details['AdministrativeArea']['SubAdministrativeArea']['SubAdministrativeAreaName']
      else
        ""
      end
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

    def precision
      @data['GeoObject']['metaDataProperty']['GeocoderMetaData']['precision']
    end

    private # ----------------------------------------------------------------

    def address_details
      @data['GeoObject']['metaDataProperty']['GeocoderMetaData']['AddressDetails']['Country']
    end

    def sub_state_city
      if sub_state && sub_state["Locality"]
        sub_state['Locality']['LocalityName']          
      else
        ""
      end
    end
  end
end
