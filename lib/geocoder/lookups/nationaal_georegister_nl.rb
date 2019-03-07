require 'geocoder/lookups/base'
require "geocoder/results/nationaal_georegister_nl"

module Geocoder::Lookup
  class NationaalGeoregisterNl < Base

    def name
      'Nationaal Georegister Nederland'
    end

    # def map_link_url(coordinates)
    #   "http://maps.google.com/maps?q=#{coordinates.join(',')}"
    # end

    # def supported_protocols
    #   # Google requires HTTPS if an API key is used.
    #   if configuration.api_key
    #     [:https]
    #   else
    #     [:http, :https]
    #   end
    # end

    private # ---------------------------------------------------------------

    def base_query_url(query)
      "#{protocol}://geodata.nationaalgeoregister.nl/locatieserver/v3/free?fl=*&q="
    end

    # def configure_ssl!(client)
    #   client.instance_eval {
    #     @ssl_context = OpenSSL::SSL::SSLContext.new
    #     options = OpenSSL::SSL::OP_NO_SSLv2 | OpenSSL::SSL::OP_NO_SSLv3
    #     if OpenSSL::SSL.const_defined?('OP_NO_COMPRESSION')
    #       options |= OpenSSL::SSL::OP_NO_COMPRESSION
    #     end
    #     @ssl_context.set_params({options: options})
    #   }
    # end

    def valid_response?(response)
      json = parse_json(response.body)
      status = json["status"] if json
      super(response) and ['OK', 'ZERO_RESULTS'].include?(status)
    end

    def results(query)
      return [] unless doc = fetch_data(query)
      return doc['response']['docs']
    end

    def query_url_google_params(query)
      params = {
        :sensor => "false",
        :language => (query.language || configuration.language)
      }
      if query.options[:google_place_id]
        params[:place_id] = query.sanitized_text
      else
        params[(query.reverse_geocode? ? :latlng : :address)] = query.sanitized_text
      end
      unless (bounds = query.options[:bounds]).nil?
        params[:bounds] = bounds.map{ |point| "%f,%f" % point }.join('|')
      end
      unless (region = query.options[:region]).nil?
        params[:region] = region
      end
      unless (components = query.options[:components]).nil?
        params[:components] = components.is_a?(Array) ? components.join("|") : components
      end
      unless (result_type = query.options[:result_type]).nil?
        params[:result_type] = result_type.is_a?(Array) ? result_type.join("|") : result_type
      end
      params
    end

    def query_url_params(query)
      query_url_google_params(query).merge(
        :key => configuration.api_key
      ).merge(super)
    end
  end
end
