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
      if state.empty? and address_details and address_details.has_key? 'Locality'
        address_details['Locality']['LocalityName']
      elsif sub_state.empty? and address_details and address_details.has_key? 'AdministrativeArea' and
          address_details['AdministrativeArea'].has_key? 'Locality'
        address_details['AdministrativeArea']['Locality']['LocalityName']
      elsif not sub_state_city.empty?
        sub_state_city
      else
        ""
      end
    end

    def country
      if address_details
        address_details['CountryName']
      else
        ""
      end
    end

    def country_code
      if address_details
        address_details['CountryNameCode']
      else
        ""
      end
    end

    def state
      if address_details and address_details['AdministrativeArea']
        address_details['AdministrativeArea']['AdministrativeAreaName']
      else
        ""
      end
    end

    def sub_state
      if !state.empty? and address_details and address_details['AdministrativeArea']['SubAdministrativeArea']
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
    
    # Yandex may return a 'Dependent Locality'
    # i.e. City of Westminster is a dependent locality of London
    def sub_city
      if (sub_city_hash = find_in_yandex_result('DependentLocality', address_details))
        sub_city_hash['DependentLocalityName']
      else
        ''
      end
    end
    
    def street
      # Street name is called ThoroughfareName
      # May be in Locality => Thoroughfare
      # Or Locality => DependentLocality => Thoroughfare
      if (street_hash = find_in_yandex_result('Thoroughfare', address_details))
        street_hash['ThoroughfareName']
      else
        ''
      end
    end
    
    def house
      find_in_yandex_result('PremiseNumber', address_details) || ''
    end

    def street
      thoroughfare_data && thoroughfare_data['ThoroughfareName']
    end

    def street_number
      thoroughfare_data && thoroughfare_data['Premise'] && thoroughfare_data['Premise']['PremiseNumber']
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

    def thoroughfare_data
      locality_data && locality_data['Thoroughfare']
    end

    def locality_data
      dependent_locality && subadmin_locality && admin_locality
    end

    def admin_locality
      address_details && address_details['AdministrativeArea'] &&
        address_details['AdministrativeArea']['Locality']
    end

    def subadmin_locality
      address_details && address_details['AdministrativeArea'] &&
        address_details['AdministrativeArea']['SubAdministrativeArea'] &&
        address_details['AdministrativeArea']['SubAdministrativeArea']['Locality']
    end

    def dependent_locality
      address_details && address_details['AdministrativeArea'] &&
        address_details['AdministrativeArea']['SubAdministrativeArea'] &&
        address_details['AdministrativeArea']['SubAdministrativeArea']['Locality'] &&
        address_details['AdministrativeArea']['SubAdministrativeArea']['Locality']['DependentLocality']
    end

    def address_details
      @data['GeoObject']['metaDataProperty']['GeocoderMetaData']['AddressDetails']['Country']
    end

    def sub_state_city
      if !sub_state.empty? and address_details and address_details['AdministrativeArea']['SubAdministrativeArea'].has_key? 'Locality'
        address_details['AdministrativeArea']['SubAdministrativeArea']['Locality']['LocalityName'] || ""
      else
        ""
      end
    end
    
    def find_in_yandex_result(key, hash)
      if hash.has_key? key 
        return hash[key]
      else
        hash.keys.each do |hash_key|
          if hash[hash_key].is_a? Hash
            return find_in_yandex_result key, hash[hash_key]
          end
        end
      end
      return nil
    end
  end
end
