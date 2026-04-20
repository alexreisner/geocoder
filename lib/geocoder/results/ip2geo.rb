require 'geocoder/results/base'

module Geocoder::Result
  class Ip2geo < Base

    def ip
      @data['ip']
    end

    def city
      @data.dig('continent', 'country', 'city', 'name') || ''
    end

    def state
      @data.dig('continent', 'country', 'subdivision', 'name') || ''
    end

    def state_code
      @data.dig('continent', 'country', 'subdivision', 'code') || ''
    end

    def country
      @data.dig('continent', 'country', 'name') || ''
    end

    def country_code
      @data.dig('continent', 'country', 'code') || ''
    end

    def postal_code
      @data.dig('continent', 'country', 'city', 'postal_code') || ''
    end

    def coordinates
      [
        @data.dig('continent', 'country', 'city', 'latitude').to_f,
        @data.dig('continent', 'country', 'city', 'longitude').to_f
      ]
    end

    def continent
      @data.dig('continent', 'name') || ''
    end

    def continent_code
      @data.dig('continent', 'code') || ''
    end

    def timezone
      @data.dig('continent', 'country', 'city', 'timezone', 'name') || ''
    end

    def phone_code
      @data.dig('continent', 'country', 'phone_code') || ''
    end

    def capital
      @data.dig('continent', 'country', 'capital') || ''
    end

    def tld
      @data.dig('continent', 'country', 'tld') || ''
    end

    def accuracy_radius
      @data.dig('continent', 'country', 'city', 'accuracy_radius')
    end

    def city_geoname_id
      @data.dig('continent', 'country', 'city', 'geoname_id')
    end

    def time_now
      @data.dig('continent', 'country', 'city', 'timezone', 'time_now') || ''
    end

    def flag_emoji
      @data.dig('continent', 'country', 'flag', 'emoji') || ''
    end

    def flag_img
      @data.dig('continent', 'country', 'flag', 'img') || ''
    end

    def currency_name
      @data.dig('continent', 'country', 'currency', 'name') || ''
    end

    def currency_code
      @data.dig('continent', 'country', 'currency', 'code') || ''
    end

    def currency_symbol
      @data.dig('continent', 'country', 'currency', 'symbol') || ''
    end

    def asn_number
      @data.dig('asn', 'number')
    end

    def asn_name
      @data.dig('asn', 'name') || ''
    end

    def registered_country
      @data.dig('registered_country', 'name') || ''
    end

    def registered_country_code
      @data.dig('registered_country', 'code') || ''
    end

    def continent_geoname_id
      @data.dig('continent', 'geoname_id')
    end

    def country_geoname_id
      @data.dig('continent', 'country', 'geoname_id')
    end

    def metro_code
      @data.dig('continent', 'country', 'city', 'metro_code')
    end

    def flag_emoji_unicode
      @data.dig('continent', 'country', 'flag', 'emoji_unicode') || ''
    end

    def registered_country_geoname_id
      @data.dig('registered_country', 'geoname_id')
    end

    def self.response_attributes
      %w[type is_eu]
    end

    response_attributes.each do |a|
      define_method a do
        @data[a]
      end
    end
  end
end
