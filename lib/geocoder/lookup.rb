require 'net/http'

module Geocoder
  module Lookup
    extend self

    ##
    # Query Google for the coordinates of the given address.
    # Returns array [lat,lon] if found, nil if not found or if network error.
    #
    def coordinates(address)
      return nil if address.blank?
      return nil unless doc = search(address, false)
      # blindly use first result (assume it is most accurate)
      place = doc['results'].first['geometry']['location']
      ['lat', 'lng'].map{ |i| place[i] }
    end

    ##
    # Query Google for the address of the given coordinates.
    # Returns string if found, nil if not found or if network error.
    #
    def address(latitude, longitude)
      return nil if latitude.blank? || longitude.blank?
      return nil unless doc = search("#{latitude},#{longitude}", true)
      # blindly use first result (assume it is most accurate)
      doc['results'].first['formatted_address']
    end


    private # ---------------------------------------------------------------

    ##
    # Query Google for geographic information about the given phrase.
    # Returns a hash representing a valid geocoder response.
    # Returns nil if non-200 HTTP response, timeout, or other error.
    #
    def search(query, reverse = false)
      doc = fetch_parsed_response(query, reverse)
      doc && doc['status'] == "OK" ? doc : nil
    end

    ##
    # Returns a parsed Google geocoder search result (hash).
    # This method is not intended for general use (prefer Geocoder.search).
    #
    def fetch_parsed_response(query, reverse = false)
      if doc = fetch_raw_response(query, reverse)
        ActiveSupport::JSON.decode(doc)
      end
    end

    ##
    # Returns a raw Google geocoder search result (JSON).
    # This method is not intended for general use (prefer Geocoder.search).
    #
    def fetch_raw_response(query, reverse = false)
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
