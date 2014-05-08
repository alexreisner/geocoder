require 'geocoder/lookups/base'
require "geocoder/results/decarta"

module Geocoder::Lookup
  class Decarta < Base

    def name
      "deCarta"
    end

    def map_link_url(coordinates)
      "http://api.decarta.com/v1/#{configuration[:api_key]}/tile/#{coordinates[0]}/#{coordinates[1]}/15"
    end

    def query_url(query)
      method = if query.reverse_geocode? 
         "reverseGeocode"
        elsif street_only?(query)
          "geocode"
        else
          "search"
        end
      host = configuration[:host] || "api-eu.decarta.com"
      "#{protocol}://#{host}/v1/#{configuration[:api_key]}/#{method}/" + custom_query_url_string(query)
    end

    private # ---------------------------------------------------------------

    def results(query)
      return [] unless docc = fetch_data(query)
      doc = docc["results"]
      doc.is_a?(Array) ? doc : [doc]
    end

    def parse_raw_data(raw_data)
      super(raw_data)
    end

    def street_only?(query)
      query.text.is_a?(Hash)
    end

    def custom_query_url_string(query)
      if query.reverse_geocode?
        lat,lon = query.coordinates
        "#{lat},#{lon}.json"
      elsif street_only?(query)
        "#{query.text[:street]},#{query.text[:city]}.json?countrySet=#{query.text[:country_iso]}&limit=3"
      else
        "#{query.sanitized_text}.json"
      end
    end
  end
end
