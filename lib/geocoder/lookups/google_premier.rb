require 'openssl'
require 'base64'
require 'geocoder/lookups/google'
require 'geocoder/results/google_premier'

module Geocoder::Lookup
  class GooglePremier < Google

    private # ---------------------------------------------------------------

    def query_url(query, reverse = false)
      params = {
        (reverse ? :latlng : :address) => query,
        :sensor => 'false',
        :language => Geocoder::Configuration.language,
        :client => Geocoder::Configuration.api_key[1],
        :channel => Geocoder::Configuration.api_key[2]
      }.reject{ |key, value| value.nil? }
      path = "/maps/api/geocode/json?#{hash_to_query(params)}"
      "#{protocol}://maps.googleapis.com#{path}&signature=#{sign(path)}"
    end

    def sign(string)
      raw_private_key = url_safe_base64_decode(Geocoder::Configuration.api_key[0])
      digest = OpenSSL::Digest::Digest.new('sha1')
      raw_signature = OpenSSL::HMAC.digest(digest, raw_private_key, string)
      url_safe_base64_encode(raw_signature)
    end

    def url_safe_base64_decode(base64_string)
      Base64.decode64(base64_string.tr('-_', '+/'))
    end

    def url_safe_base64_encode(raw)
      Base64.encode64(raw).tr('+/', '-_').strip
    end
  end
end
