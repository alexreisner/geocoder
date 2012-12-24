require 'geocoder/results/base'

module Geocoder::Result
  class Maxmind < Base

    ##
    # Hash mapping service names to names of returned fields.
    #
    def self.field_names
      {
        :country => [
          :country_code,
          :error
        ],

        :city => [
          :country_code,
          :region_code,
          :city_name,
          :latitude,
          :longitude,
          :error
        ],

        :city_isp_org => [
          :country_code,
          :region_code,
          :city_name,
          :postal_code,
          :latitude,
          :longitude,
          :metro_code,
          :area_code,
          :isp_name,
          :organization_name,
          :error
        ],

        :omni => [
          :country_code,
          :country_name,
          :region_code,
          :region_name,
          :city_name,
          :latitude,
          :longitude,
          :metro_code,
          :area_code,
          :time_zone,
          :continent_code,
          :postal_code,
          :isp_name,
          :organization_name,
          :domain,
          :as_number,
          :netspeed,
          :user_type,
          :accuracy_radius,
          :country_confidence_factor,
          :city_confidence_factor,
          :region_confidence_factor,
          :postal_confidence_factor,
          :error
        ]
      }
    end

    ##
    # Name of the MaxMind service being used.
    # Inferred from format of @data.
    #
    def service_name
      self.class.field_names.to_a.each do |n,f|
        return n if f.size == @data.size
      end
      nil
    end

    def field_names
      self.class.field_names[service_name]
    end

    def data_hash
      @data_hash ||= Hash[*field_names.zip(@data).flatten]
    end

    def coordinates
      [data_hash[:latitude].to_f, data_hash[:longitude].to_f]
    end

    def address(format = :full)
      s = state_code.to_s == "" ? "" : ", #{state_code}"
      "#{city}#{s} #{postal_code}, #{country_code}".sub(/^[ ,]*/, "")
    end

    def city
      data_hash[:city_name]
    end

    def state # not given by MaxMind
      data_hash[:region_name] || data_hash[:region_code]
    end

    def state_code
      data_hash[:region_code]
    end

    def country #not given by MaxMind
      data_hash[:country_name] || data_hash[:country_code]
    end

    def country_code
      data_hash[:country_code]
    end

    def postal_code
      data_hash[:postal_code]
    end

    def method_missing(method, *args, &block)
      if field_names.include?(method)
        data_hash[method]
      else
        super
      end
    end

    def respond_to?(method)
      if field_names.include?(method)
        true
      else
        super
      end
    end
  end
end
