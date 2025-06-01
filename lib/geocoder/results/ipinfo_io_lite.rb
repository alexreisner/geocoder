require 'geocoder/results/base'

module Geocoder::Result
  class IpinfoIoLite < Base

    def asn
      @data['asn']
    end

    def as_name
      @data['as_name']
    end

    def as_domain
      @data['as_domain']
    end

    def country
      @data['country']
    end

    def country_code
      @data.fetch('country', '')
    end

    def continent
      @data['continent']
    end

    def continent_code
      @data['continent_code']
    end

    def self.response_attributes
      %w(ip asn as_name as_domain country country_code continent continent_code)
    end

    response_attributes.each do |a|
      define_method a do
        @data[a]
      end
    end
  end
end
