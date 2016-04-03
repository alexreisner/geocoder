require 'geocoder/results/base'

module Geocoder::Result
  class IpapiCom < Base

    def latitude
      lat
    end

    def longitude
      lon
    end

    def coordinates
      [lat, lon]
    end

    def address
      "#{city}, #{state_code} #{postal_code}, #{country}".sub(/^[ ,]*/, "")
    end

    def state
      region_name
    end

    def state_code
      region
    end

    def postal_code
      zip
    end

    def country_code
      @data.fetch('countryCode', '')
    end

    def region_name
      @data.fetch('regionName', '')
    end


    class << self

      def fields
        %w[country countryCode region regionName city zip lat lon timezone isp org as reverse mobile proxy query status message]
      end

      def response_attributes
        response_string_attributes + response_boolean_attributes + response_float_attributes
      end

      def response_string_attributes
        %w[country region city zip timezone isp org as reverse query status message]
      end

      def response_boolean_attributes
        %w[mobile proxy]
      end

      def response_float_attributes
        %w[lat lon]
      end

      def define_fetch_methods(attributes, default_value)
        attributes.each do |attribute|
          define_method attribute do
            @data.fetch(attribute, default_value)
          end
        end
      end

    end

    define_fetch_methods(response_string_attributes, '')

    define_fetch_methods(response_boolean_attributes, nil)

    define_fetch_methods(response_float_attributes, 0.0.to_f)

  end
end
