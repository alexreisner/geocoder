require 'openssl'
require 'base64'
require 'geocoder/lookups/google'
require 'geocoder/results/google_premier'

module Geocoder::Lookup
  class GooglePremier < Google

    private # ---------------------------------------------------------------

    def query_url_params(query)
      super.merge(query_url_google_params(query)).merge(
        :key => nil, # don't use param inherited from Google lookup
        :client => Geocoder::Configuration.api_key[1],
        :channel => Geocoder::Configuration.api_key[2]
      )
    end

    def query_url(query)
      path = "/maps/api/geocode/json?" + url_query_string(query)
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
