require 'geocoder/lookups/base'
require "geocoder/results/geocoder_ca"

module Geocoder::Lookup
  class GeocoderCa < Base

    private # ---------------------------------------------------------------

    def results(query, reverse = false)
      return [] unless doc = fetch_data(query, reverse)
      if doc['error'].nil?
        return [doc]
      elsif doc['error']['code'] == "005"
        # "Postal Code is not in the proper Format" => no results, just shut up
      else
        warn "Geocoder.ca service error: #{doc['error']['code']} (#{doc['error']['description']})."
      end
      return []
    end

    def query_url(query, reverse = false)
      params = {
        :geoit    => "xml",
        :jsonp    => 1,
        :callback => "test",
        :auth     => Geocoder::Configuration.api_key
      }
      if reverse
        lat,lon = query.split(',')
        params[:latt] = lat
        params[:longt] = lon
        params[:corner] = 1
        params[:reverse] = 1
      else
        params[:locate] = query
      end
      "http://geocoder.ca/?" + hash_to_query(params)
    end

    def parse_raw_data(raw_data)
      super raw_data[/^test\((.*)\)\;\s*$/, 1]
    end
  end
end

