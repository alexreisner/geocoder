require 'geocoder/results/base'

module Geocoder::Result
  class PostcodeanywhereUk < Base
    def coordinates
      [@data['Latitude'], @data['Longitude']]
    end

    def city
      location_tokens.last
    end

    def blank_result
      ''
    end
    alias_method :state, :blank_result
    alias_method :state_code, :blank_result
    alias_method :postal_code, :blank_result

    def country
      'United Kingdom'
    end

    def country_code
      'UK'
    end

    def address
      [@data['Location'], @data['OsGrid']].join(', ')
    end

    # def address(format = :full)
    #   @data['Location'], @data['Os']
    # end

    # def city
    #   location_tokens.last
    # end

    # def state_code
    #   if state = address_components_of_type(:administrative_area_level_1).first
    #     state['short_name']
    #   end
    # end

    # def country
    #   'United Kingdom'
    # end

    # def country_code
    #   'UK'
    # end

    private
    def location_tokens
      @location_tokens ||= @data['Location'].split(', ')
    end
  end
end