require 'geocoder/lookups/base'

module Geocoder::Lookup
  class GoogleBase < Base
    def supported_protocols
      # Google requires HTTPS if an API key is used.
      if configuration.api_key
        [:https]
      else
        [:http, :https]
      end
    end

    private # ---------------------------------------------------------------

    def configure_ssl!(client)
      client.instance_eval {
        @ssl_context = OpenSSL::SSL::SSLContext.new
        options = OpenSSL::SSL::OP_NO_SSLv2 | OpenSSL::SSL::OP_NO_SSLv3
        if OpenSSL::SSL.const_defined?('OP_NO_COMPRESSION')
          options |= OpenSSL::SSL::OP_NO_COMPRESSION
        end
        @ssl_context.set_params({options: options})
      }
    end
  end
end

