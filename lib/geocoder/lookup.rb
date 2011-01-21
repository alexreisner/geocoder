module Geocoder
  module Lookup
    extend self

    ##
    # Query Google for the coordinates of the given phrase.
    # Returns array [lat,lon] if found, nil if not found or if network error.
    #
    def coordinates(query)
      return nil unless doc = search(query)
      # blindly use the first results (assume they are most accurate)
      place = doc['results'].first['geometry']['location']
      ['lat', 'lng'].map{ |i| place[i] }
    end


    private # ---------------------------------------------------------------

    ##
    # Query Google for geographic information about the given phrase.
    # Returns a hash representing a valid geocoder response.
    # Returns nil if non-200 HTTP response, timeout, or other error.
    #
    def search(query)
      doc = fetch_parsed_response(query)
      doc && doc['status'] == "OK" ? doc : nil
    end

    ##
    # Returns a parsed Google geocoder search result (hash).
    # This method is not intended for general use (prefer Geocoder.search).
    #
    def fetch_parsed_response(query)
      if doc = fetch_raw_response(query)
        ActiveSupport::JSON.decode(doc)
      end
    end

    ##
    # Returns a raw Google geocoder search result (JSON).
    # This method is not intended for general use (prefer Geocoder.search).
    #
    def fetch_raw_response(query)
      return nil if query.blank?

      # build URL
      params = { :address => query, :sensor  => "false" }
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
