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
        state['Locality']['LocalityName']
      else 
        sub_state['Locality']['LocalityName']
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
      if !state.empty?
        if state['SubAdministrativeArea']
          state['SubAdministrativeArea']['SubAdministrativeAreaName']
        else
          ""
        end
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

    private # ----------------------------------------------------------------

    def address_details
      @data['GeoObject']['metaDataProperty']['GeocoderMetaData']['AddressDetails']['Country']
    end
  end
end
