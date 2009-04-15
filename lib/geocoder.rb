##
# Add geocoding functionality (via Google) to any object that implements
# a +location+ method that returns a string suitable for a Google Maps search.
#
module Geocoder
  
  ##
  # Query Google for the coordinates of the given phrase.
  # Returns array [lat,lon] if found.
  #
  def self.fetch_coordinates(query)
    data = self.search(query)
    
    # Make sure search found a result.
    return nil unless data['kml']['response']['status']['code'] == "200"
    place = data['kml']['response']['placemark']

    # If there are multiple results, blindly use the first.
    place = place.first if place.is_a?(Array)
    coords = place['point']['coordinates']
    coords.split(',')[0...2].reverse.map{ |i| i.to_f }
  end
  
  ##
  # Search Google based on the object's +location+ attribute.
  #
  def fetch_coordinates
    Geocoder.fetch_coordinates(location)
  end
  
  ##
  # Fetch and assign +latitude+ and +longitude+ if +location+ has changed.
  #
  def assign_coordinates
    if location_changed? and c = fetch_coordinates
      self.latitude = c[0]
      self.longitude = c[1]
    end
  end

  ##
  # Find all records within a radius (in miles) of the given point.
  # Taken from excellent tutorial at:
  # http://www.scribd.com/doc/2569355/Geo-Distance-Search-with-MySQL
  #
  def self.nearby_mysql_query(table, latitude, longitude, radius = 20, options = {})
    
    # Alternate column names.
    options[:latitude]  ||= 'latitude'
    options[:longitude] ||= 'longitude'
    
    # Constrain search to a (radius x radius) square.
    factor = (Math::cos(latitude * Math::PI / 180.0) * 69.0).abs
    lon_lo = longitude - (radius / factor);
    lon_hi = longitude + (radius / factor);
    lat_lo = latitude  - (radius / 69.0);
    lat_hi = latitude  + (radius / 69.0);
    where  = "#{options[:latitude]} BETWEEN #{lat_lo} AND #{lat_hi} AND " +
      "#{options[:longitude]} BETWEEN #{lon_lo} AND #{lon_hi}"

    # Generate query.
    "SELECT *, 3956 * 2 * ASIN(SQRT(" +
      "POWER(SIN((#{latitude} - #{options[:latitude]}) * " +
      "PI() / 180 / 2), 2) + COS(#{latitude} * PI()/180) * " +
      "COS(#{options[:latitude]} * PI() / 180) * " +
      "POWER(SIN((#{longitude} - #{options[:longitude]}) * " +
      "PI() / 180 / 2), 2) )) as distance " +
      "FROM #{table} WHERE #{where} HAVING distance <= #{radius}"
  end

  ##
  # Query Google for geographic information about the given phrase.
  # Returns the XML response as a hash. This method is not intended for
  # general use (prefer Geocoder.search).
  #
  def self.search(query)
    params = { :q => query, :output => "xml" }
    url    = "http://maps.google.com/maps/geo?" + params.to_query
    
    # Query geocoder and make sure it responds quickly.
    begin
      resp = nil
      timeout(3) do
        resp = Net::HTTP.get_response(URI.parse(url))
      end
    rescue SocketError, TimeoutError
      return nil
    end

    # Google's XML document has incorrect encoding (says UTF-8 but is actually
    # ISO 8859-1). Have to fix this or REXML won't parse correctly.
    # This may be fixed in the future; see the bug report at:
    # http://code.google.com/p/gmaps-api-issues/issues/detail?id=233
    doc = resp.body.sub('UTF-8', 'ISO-8859-1')

    Hash.from_xml(doc)
  end
end
