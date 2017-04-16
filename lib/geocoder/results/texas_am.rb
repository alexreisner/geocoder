require 'geocoder/results/base'

module Geocoder::Result
  class TexasAm < Base

    def latitude
      @data['lat']
    end

    def longitude
      @data['lon']
    end

    def coordinates
      [latitude, longitude]
    end

    def city
      @data['city']
    end

    def street
      @data['streetaddr']
    end

    def state
      @data['state']
    end

    def zip
      @data['zip']
    end

    # Texas A&M does not provide this data so assume only USA
    def country
      'United States'
    end

    # Texas A&M does not provide this data so assume only USA
    def country_code
      'US'
    end

    alias_method :state_code, :state
    alias_method :province, :state
    alias_method :province_code, :state
    alias_method :postal_code, :zip

    def address
      [street, city, state, postal_code].reject{|s| s.length == 0 }.join(', ')
    end

  end
end
