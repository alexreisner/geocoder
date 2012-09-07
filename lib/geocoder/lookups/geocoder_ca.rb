require 'geocoder/lookups/base'
require "geocoder/results/geocoder_ca"

module Geocoder::Lookup
  class GeocoderCa < Base

    private # ---------------------------------------------------------------

    def results(query)
      return [] unless doc = fetch_data(query)
      if doc['error'].nil?
        return [doc]
      elsif doc['error']['code'] == "005"
        # "Postal Code is not in the proper Format" => no results, just shut up
      else
        warn "Geocoder.ca service error: #{doc['error']['code']} (#{doc['error']['description']})."
      end
      return []
    end

    def query_url_params(query)
      params = super.merge(
        :geoit    => "xml",
        :jsonp    => 1,
        :callback => "test",
        :auth     => Geocoder::Configuration.api_key
      )
      if query.reverse_geocode?
        lat,lon = query.coordinates
        params[:latt] = lat
        params[:longt] = lon
        params[:corner] = 1
        params[:reverse] = 1
      else
        params[:locate] = query.sanitized_text
        params[:showpostal] = 1
      end
      params
    end

    def query_url(query)
      "http://geocoder.ca/?" + url_query_string(query)
    end

    def parse_raw_data(raw_data)
      super raw_data[/^test\((.*)\)\;\s*$/, 1]
    end
  end
end

