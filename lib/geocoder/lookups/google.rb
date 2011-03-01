require 'geocoder/lookups/base'

module Geocoder::Lookup
  class Google < Base

    def coordinates(address)
      if (results = search(address)).size > 0
        place = results.first.geometry['location']
        ['lat', 'lng'].map{ |i| place[i] }
      end
    end

    def address(latitude, longitude)
      if (results = search(latitude, longitude)).size > 0
        results.first.formatted_address
      end
    end

    def search(*args)
      return [] if args[0].blank?
      doc = parsed_response(args.join(","), args.size == 2)
      [].tap do |results|
        if doc
          doc['results'].each{ |r| results << Geocoder::Result.new(r) }
        end
      end
    end


    private # ---------------------------------------------------------------

    ##
    # Returns a parsed Google geocoder search result (hash).
    # Returns nil if non-200 HTTP response, timeout, or other error.
    #
    def parsed_response(query, reverse = false)
      doc = fetch_data(query, reverse)
      case doc['status']; when "OK"
        doc
      when "OVER_QUERY_LIMIT"
        warn "Google Geocoding API error: over query limit."
      when "REQUEST_DENIED"
        warn "Google Geocoding API error: request denied."
      when "INVALID_REQUEST"
        warn "Google Geocoding API error: invalid request."
      end
    end

    def query_url(query, reverse = false)
      params = {
        (reverse ? :latlng : :address) => query,
        :sensor => "false"
      }
      "http://maps.google.com/maps/api/geocode/json?" + params.to_query
    end
  end
end

