require 'net/http'

module Geocoder
  module Lookup
    extend self

    ##
    # Query Google for the coordinates of the given address.
    #
    def coordinates(address)
      if (results = search(address)).size > 0
        place = results.first.geometry['location']
        ['lat', 'lng'].map{ |i| place[i] }
      end
    end

    ##
    # Query Google for the address of the given coordinates.
    #
    def address(latitude, longitude)
      if (results = search(latitude, longitude)).size > 0
        results.first.formatted_address
      end
    end

    ##
    # Takes a search string (eg: "Mississippi Coast Coliseumf, Biloxi, MS") for
    # geocoding, or coordinates (latitude, longitude) for reverse geocoding.
    # Returns an array of Geocoder::Result objects,
    # or nil if not found or if network error.
    #
    def search(*args)
      return nil if args[0].blank?
      doc = parsed_response(args.join(","), args.size == 2)
      [].tap do |results|
        if doc
          doc['results'].each{ |r| results << Result.new(r) }
        end
      end
    end


    private # ---------------------------------------------------------------

    ##
    # Returns a parsed Google geocoder search result (hash).
    # Returns nil if non-200 HTTP response, timeout, or other error.
    #
    def parsed_response(query, reverse = false)
      if doc = raw_response(query, reverse)
        doc = ActiveSupport::JSON.decode(doc)
        doc && doc['status'] == "OK" ? doc : nil
      end
    end

    ##
    # Returns a raw Google geocoder search result (JSON).
    #
    def raw_response(query, reverse = false)
      return nil if query.blank?

      # name parameter based on forward/reverse geocoding
      param = reverse ? :latlng : :address

      # build URL
      params = { param => query, :sensor  => "false" }
      url = "http://maps.google.com/maps/api/geocode/json?" + params.to_query

      # query geocoder and make sure it responds quickly
      begin
        resp = nil
        timeout(3) do
          Net::HTTP.get_response(URI.parse(url)).body
        end
      rescue SocketError, TimeoutError
        return nil
      end
    end
  end
end
