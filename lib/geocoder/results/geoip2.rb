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
        fetch_name(
          data.fetch('city', {}).fetch('names', {})
        )
      end

      def state
        fetch_name(
          data.fetch('subdivisions', []).fetch(0, {}).fetch('names', {})
        )
      end

      def state_code
        data.fetch('subdivisions', []).fetch(0, {}).fetch('iso_code', '')
      end

      def country
        fetch_name(
          data.fetch('country', {}).fetch('names', {})
        )
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

      def language=(l)
        @language = l.to_s
      end

      def language
        @language ||= default_language
      end

      private

      def data
        @data.to_hash
      end

      def default_language
        @default_language = Geocoder.config[:language].to_s
      end

      def fetch_name(names)
        names[language] || names[default_language] || ''
      end
    end
  end
end
