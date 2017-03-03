require 'geocoder/results/base'

module Geocoder
  module Result
    class Geoip2 < Base
      def address(format = :full)
        s = state.to_s == '' ? '' : ", #{state_code}"
        "#{city}#{s} #{postal_code}, #{country}".sub(/^[ ,]*/, '')
      end

      def coordinates
        %w[latitude longitude].map do |l|
          data.fetch('location', {}).fetch(l, 0.0)
        end
      end

      def city
        data.fetch('city', {}).fetch('names', {}).fetch(locale, '')
      end

      def state
        data.fetch('subdivisions', []).fetch(0, {}).fetch('names', {}).fetch(locale, '')
      end

      def state_code
        data.fetch('subdivisions', []).fetch(0, {}).fetch('iso_code', '')
      end

      def country
        data.fetch('country', {}).fetch('names', {}).fetch(locale, '')
      end

      def country_code
        data.fetch('country', {}).fetch('iso_code', '')
      end

      def postal_code
        data.fetch('postal', {}).fetch('code', '')
      end

      def self.response_attributes
        %w[ip]
      end

      response_attributes.each do |a|
        define_method a do
          @data[a]
        end
      end

      private

      def data
        @data.to_hash
      end

      def locale
        defined?(I18n) ? I18n.locale.to_s : Geocoder.config[:language].to_s
      end
    end
  end
end
