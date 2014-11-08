require 'geocoder/results/base'

module Geocoder
  module Result
    class Geoip2 < Base
      def address(format = :full)
        s = state.to_s == '' ? '' : ", #{state_code}"
        "#{city}#{s} #{postal_code}, #{country}".sub(/^[ ,]*/, '')
      end

      def coordinates
        [latitude, longitude]
      end

      def latitude
        return 0.0 unless @data['location']
        @data['location']['latitude'].to_f
      end

      def longitude
        return 0.0 unless @data['location']
        @data['location']['longitude'].to_f
      end

      def city
        return '' unless @data['city']
        @data['city']['names']['en']
      end

      def state
        return '' unless @data['subdivisions']
        @data['subdivisions'][0]['names']['en']
      end

      def state_code
        return '' unless @data['subdivisions']
        @data['subdivisions'][0]['iso_code']
      end

      def country
        @data['country']['names']['en']
      end

      def country_code
        @data['country']['iso_code']
      end

      def postal_code
        return '' unless @data['postal']
        @data['postal']['code']
      end

      def self.response_attributes
        %w[ip]
      end

      response_attributes.each do |a|
        define_method a do
          @data[a]
        end
      end
    end
  end
end
