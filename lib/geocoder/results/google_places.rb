require 'geocoder/results/base'

module Geocoder::Result
  class GooglePlaces < Base

    def initialize(data)
      super(data)
      @google_details = nil
    end

    def coordinates
      ['lat', 'lng'].map{ |i| geometry['location'][i] }
    end

    def address(format = :full)
      formatted_address
    end

    def city
      get_details if @google_details.nil?
      return @google_details.nil? ? nil : @google_details.city
    end

    def state
      get_details if @google_details.nil?
      return @google_details.nil? ? nil : @google_details.state
    end

    def state_code
      get_details if @google_details.nil?
      return @google_details.nil? ? nil : @google_details.state_code
    end

    def country
      get_details if @google_details.nil?
      return @google_details.nil? ? nil : @google_details.country
    end

    def country_code
      get_details if @google_details.nil?
      return @google_details.nil? ? nil : @google_details.country_code
    end

    def postal_code
      get_details if @google_details.nil?
      return @google_details.nil? ? nil : @google_details.postal_code
    end


    def formatted_address
      @data['formatted_address']
    end

    def geometry
      @data['geometry']
    end

    def reference
      @data['reference']
    end

    def get_details
      if (@google_details.nil?)
        details = Geocoder::Lookup::GoogleDetails.new().search(reference)
        @google_details = details[0]
      end
      return @google_details
    end

    # additional
    def rating
      @data['rating']
    end

    def types
      @data['types']
    end

    def icon
      @data['icon']
    end

  end
end
