require 'geocoder/results/base'

module Geocoder::Result
  class Bing < Base

    def address(format = :full)
      data_address['formattedAddress']
    end

    def city
      data_address['locality']
    end

    def country
      data_address['countryRegion']
    end
    
    def country_code
      # Bing does not return a contry code
      ""
    end

    def postal_code
      data_address['postalCode']
    end
    
    def coordinates
      data_coordinates['coordinates']
    end
    
    def data_address
      @data['address']
    end
    
    def data_coordinates
      @data['point']
    end
    
    def address_line
      data_address['addressLine']
    end
    
    def state
      data_address['adminDistrict']
    end
    
    def confidence
      @data['confidence']
    end
  end
end
