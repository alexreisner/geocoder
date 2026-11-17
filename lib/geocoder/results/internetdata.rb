require 'geocoder/results/base'

module Geocoder::Result
  class Internetdata < Base

    def coordinates
      [location['latitude'], location['longitude']]
    end

    def address(format = :full)
      [city, state, country].reject { |s| s.to_s.empty? }.join(', ')
    end

    def city
      location['city']
    end

    def state
      location['region']
    end

    def state_code
      location['region_code']
    end

    def postal_code
      location['postal_code']
    end

    def country
      location['country_name']
    end

    def country_code
      location['country']
    end

    # methods for fields specific to InternetData

    def ip
      @data['ip']
    end

    def time_zone
      location['timezone']
    end

    def continent_code
      location['continent']
    end

    def hostname
      @data['hostname']
    end

    def asn
      section('asn')['asn']
    end

    def as_name
      section('asn')['name']
    end

    def company_name
      section('company')['name']
    end

    def company_domain
      section('company')['domain']
    end

    def abuse_email
      section('abuse')['email']
    end

    def bogon?
      @data['is_bogon'] == true
    end

    def tor?
      @data['is_tor'] == true
    end

    private

    def location
      section('location')
    end

    def section(key)
      @data[key].is_a?(Hash) ? @data[key] : {}
    end
  end
end
