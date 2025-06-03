require 'geocoder/results/base'

module Geocoder::Result
  class IpinfoIoLite < Base

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
