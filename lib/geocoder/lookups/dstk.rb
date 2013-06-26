# More information about the Data Science Toolkit can be found at:
# http://www.datasciencetoolkit.org/. The provided APIs mimic the
# Google geocoding api.

require 'geocoder/lookups/google'
require 'geocoder/results/dstk'

module Geocoder::Lookup
  class Dstk < Google

    def name
      "Data Science Toolkit"
    end

    def query_url(query)
      host = configuration[:host] || "www.datasciencetoolkit.org"
      "#{protocol}://#{host}/maps/api/geocode/json?" + url_query_string(query)
    end
  end
end
