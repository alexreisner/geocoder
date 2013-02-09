require 'geocoder/results/base'

module Geocoder::Result
  class Ovi < Base

    ##
    # A string in the given format.
    #
    def address(format = :full)
      fail unless d = @data['Location']['Address']
      d['Label']
    end

    ##
    # A two-element array: [lat, lon].
    #
    def coordinates
      fail unless d = @data['Location']['DisplayPosition']
      [d['Latitude'].to_f, d['Longitude'].to_f]
    end

    def state
      fail unless d = @data['Location']['Address']
      d['County']
    end

    def province
      fail unless d = @data['Location']['Address']
      d['County']
    end

    def postal_code
      fail unless d = @data['Location']['Address']
      d['PostalCode']
    end

    def city
      fail unless d = @data['Location']['Address']
      d['City']
    end

    def state_code
      fail unless d = @data['Location']['Address']
      d['State']
    end

    def province_code
      fail unless d = @data['Location']['Address']
      d['State']
    end

    def country
      fail unless d = @data['Location']['Address']['AdditionalData']
      if v = d.find{|ad| ad['key']=='CountryName'}
        return v['value']
      end
    end

    def country_code
      fail unless d = @data['Location']['Address']
      d['Country']
    end
  end
end
