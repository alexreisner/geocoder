require "#{File.dirname(__FILE__)}/base"

module Geocoder::Result
  class Ipgeobase < Base

    def address(format = :full)      
      "#{city}, #{state}, #{country}".sub(/^[ ,]*/, "")
    end  

    def city
      @data['city']
    end

    def ip
      @data['value']
    end

    def state
      @data['region']
    end

    def country_code
      @data['country']
    end

    def latitude
      @data['lat'].to_f
    end

    def longitude
      @data['lng'].to_f
    end

    def coordinates
      [self.latitude, self.longitude]
    end

    def state_code
      ''
    end

    def postal_code
      ''
    end

    def self.response_attributes
      %w[value inetnum country city region district lat lng]
    end

    response_attributes.each do |a|
      define_method a do
        @data[a]
      end
    end
  end
end