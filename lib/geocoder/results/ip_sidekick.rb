require 'geocoder/results/base'

module Geocoder::Result
  class IpSidekick < Base

    def address(format = :full)
      ''
    end

    def latitude
      0.0
    end

    def longitude
      0.0
    end

    def country
      @data.fetch('country', {}).fetch('name', '')
    end

    def country_code
      @data.fetch('country', {}).fetch('code', '')
    end

    def currency
      @data.fetch('currency', {}).fetch('name', '')
    end

    def currency_code
      @data.fetch('currency', {}).fetch('code', '')
    end

    def currency_decimals
      @data.fetch('currency', {}).fetch('decimals', '')
    end

    def timezone
      @data.fetch('timeZone', {}).fetch('name', '')
    end

    def gmt_offset
      @data.fetch('timeZone', {}).fetch('gmtOffset', '')
    end

    def self.response_attributes
      %w(ip holiday)
    end

    response_attributes.each do |a|
      define_method a do
        @data[a]
      end
    end

    def self.unsupported_response_attributes
      %w(city state postal_code state_code)
    end

    unsupported_response_attributes.each do |a|
      define_method a do
        ''
      end
    end
  end
end
