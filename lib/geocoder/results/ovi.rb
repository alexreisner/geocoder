require 'geocoder/results/base'

module Geocoder::Result
  class Ovi < Base

    ##
    # A string in the given format.
    #
    def address(format = :full)
      address_data['Label']
    end

    ##
    # A two-element array: [lat, lon].
    #
    def coordinates
      fail unless d = @data['Location']['DisplayPosition']
      [d['Latitude'].to_f, d['Longitude'].to_f]
    end

    def state
      address_data['County']
    end

    def province
      address_data['County']
    end

    def postal_code
      address_data['PostalCode']
    end

    def city
      address_data['City']
    end

    def state_code
      address_data['State']
    end

    def province_code
      address_data['State']
    end

    def country
      fail unless d = address_data['AdditionalData']
      if v = d.find{|ad| ad['key']=='CountryName'}
        return v['value']
      end
    end

    def country_code
      address_data['Country']
    end

    def viewport
      map_view = data['Location']['MapView'] || fail
      south = map_view['BottomRight']['Latitude']
      west = map_view['TopLeft']['Longitude']
      north = map_view['TopLeft']['Latitude']
      east = map_view['BottomRight']['Longitude']
      [south, west, north, east]
    end

    private # ----------------------------------------------------------------

    def address_data
      @data['Location']['Address'] || fail
    end
  end
end
