# -*- encoding: utf-8 -*-
require 'geocoder/results/base'

module Geocoder::Result
  class Geoplugin < Base

    def coordinates
      [@data['geoplugin_latitude'].to_f, @data['geoplugin_longitude'].to_f]
    end

    def address
      [city, province, country].compact.join(', ')
    end

    def state
      province
    end
    
    def province
      @data['geoplugin_region'].presence
    end

    def city
      @data['geoplugin_city'].presence
    end

    def country
      @data['geoplugin_countryName'].presence
    end

    def country_code
      @data['geoplugin_countryCode']
    end

    def currency_code
      @data['geoplugin_currencyCode']
    end

    def currency
      @data['geoplugin_currencyConverter'].to_f
    end

  end
end

class Object
  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end

  def present?
    !blank?
  end

  def presence
    self if present?
  end
end