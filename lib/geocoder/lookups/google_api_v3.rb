require 'openssl'
require 'base64'

require 'geocoder/lookups/google'
require 'geocoder/results/google_api_v3'

require 'geocoder/lookups/route/google_api_v3'


module Geocoder::Lookup
  class GoogleApiV3 < Google
    include Geocoder::Lookup::Route::GoogleApiV3
    

    private # ---------------------------------------------------------------

    

    def query_url(query, reverse = false)
      params = {
        (reverse ? :latlng : :address) => query,
        :sensor => 'false',
        :language => Geocoder::Configuration.language
      }.reject{ |key, value| value.nil? }
      path = "/maps/api/geocode/json?#{hash_to_query(params)}"
      "#{protocol}://maps.googleapis.com#{path}"
    end

    

    def url_safe_base64_decode(base64_string)
      Base64.decode64(base64_string.tr('-_', '+/'))
    end

    def url_safe_base64_encode(raw)
      Base64.encode64(raw).tr('+/', '-_').strip
    end
  end
end
