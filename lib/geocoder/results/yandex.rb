require 'geocoder/results/base'

module Geocoder::Result
  class Yandex < Base
    ADDRESS_DETAILS = %w[
      GeoObject metaDataProperty GeocoderMetaData
      AddressDetails
    ].freeze

    COUNTRY_LEVEL = %w[
      GeoObject metaDataProperty GeocoderMetaData
      AddressDetails Country
    ].freeze

    ADMIN_LEVEL = %w[
      GeoObject metaDataProperty GeocoderMetaData
      AddressDetails Country
      AdministrativeArea
    ].freeze

    SUBADMIN_LEVEL = %w[
      GeoObject metaDataProperty GeocoderMetaData
      AddressDetails Country
      AdministrativeArea
      SubAdministrativeArea
    ].freeze

    DEPENDENT_LOCALITY_1 = %w[
      GeoObject metaDataProperty GeocoderMetaData
      AddressDetails Country
      AdministrativeArea Locality
      DependentLocality
    ].freeze

    DEPENDENT_LOCALITY_2 = %w[
      GeoObject metaDataProperty GeocoderMetaData
      AddressDetails Country
      AdministrativeArea
      SubAdministrativeArea Locality
      DependentLocality
    ].freeze

    def coordinates
      @data['GeoObject']['Point']['pos'].split(' ').reverse.map(&:to_f)
    end

    def address(_format = :full)
      @data['GeoObject']['metaDataProperty']['GeocoderMetaData']['text']
    end

    def city
      result =
        if state.empty?
          dig_data(@data, *COUNTRY_LEVEL, 'Locality', 'LocalityName')
        elsif sub_state.empty?
          dig_data(@data, *ADMIN_LEVEL, 'Locality', 'LocalityName')
        else
          dig_data(@data, *SUBADMIN_LEVEL, 'Locality', 'LocalityName')
        end

      result || ""
    end

    def country
      dig_data(@data, *COUNTRY_LEVEL, 'CountryName') || ""
    end

    def country_code
      dig_data(@data, *COUNTRY_LEVEL, 'CountryNameCode') || ""
    end

    def state
      dig_data(@data, *ADMIN_LEVEL, 'AdministrativeAreaName') || ""
    end

    def sub_state
      return "" if state.empty?
      dig_data(@data, *SUBADMIN_LEVEL, 'SubAdministrativeAreaName') || ""
    end

    def state_code
      ""
    end

    def street
      thoroughfare_data.is_a?(Hash) ? thoroughfare_data['ThoroughfareName'] : ""
    end

    def street_number
      premise.is_a?(Hash) ? premise.fetch('PremiseNumber', "") : ""
    end

    def premise_name
      premise.is_a?(Hash) ? premise.fetch('PremiseName', "") : ""
    end

    def postal_code
      return "" unless premise.is_a?(Hash)
      dig_data(premise, 'PostalCode', 'PostalCodeNumber') || ""
    end

    def kind
      @data['GeoObject']['metaDataProperty']['GeocoderMetaData']['kind']
    end

    def precision
      @data['GeoObject']['metaDataProperty']['GeocoderMetaData']['precision']
    end

    def viewport
      envelope = @data['GeoObject']['boundedBy']['Envelope'] || fail
      east, north = envelope['upperCorner'].split(' ').map(&:to_f)
      west, south = envelope['lowerCorner'].split(' ').map(&:to_f)
      [south, west, north, east]
    end

    private # ----------------------------------------------------------------

    def top_level_locality
      dig_data(@data, *ADDRESS_DETAILS, 'Locality')
    end

    def country_level_locality
      dig_data(@data, *COUNTRY_LEVEL, 'Locality')
    end

    def admin_locality
      dig_data(@data, *ADMIN_LEVEL, 'Locality')
    end

    def subadmin_locality
      dig_data(@data, *SUBADMIN_LEVEL, 'Locality')
    end

    def dependent_locality
      dig_data(@data, *DEPENDENT_LOCALITY_1) ||
        dig_data(@data, *DEPENDENT_LOCALITY_2)
    end

    def locality_data
      dependent_locality || subadmin_locality || admin_locality ||
        country_level_locality || top_level_locality
    end

    def thoroughfare_data
      locality_data['Thoroughfare'] if locality_data.is_a?(Hash)
    end

    def premise
      if thoroughfare_data.is_a?(Hash)
        thoroughfare_data['Premise']
      elsif locality_data.is_a?(Hash)
        locality_data['Premise']
      end
    end

    def dig_data(source, *keys)
      key = keys.shift
      result = source.fetch(key, nil)
      return result unless result.is_a?(Hash)
      keys.any? ? dig_data(result, *keys) : result
    end
  end
end
