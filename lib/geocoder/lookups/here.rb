require 'geocoder/lookups/base'
require 'geocoder/results/here'

module Geocoder::Lookup
  class Here < Base

    def name
      "Here"
    end

    def required_api_key_parts
      ['api_key']
    end

    def supported_protocols
      [:https]
    end

    private # ---------------------------------------------------------------

    def base_query_url(query)
      "#{protocol}://#{if query.reverse_geocode? then 'reverse.' end}geocoder.ls.hereapi.com/6.2/#{if query.reverse_geocode? then 'reverse' end}geocode.json?"
    end

    def results(query)
      return [] unless doc = fetch_data(query)
      return [] unless doc['Response'] && doc['Response']['View']
      if r=doc['Response']['View']
        return [] if r.nil? || !r.is_a?(Array) || r.empty?
        return r.first['Result']
      end
      []
    end

    def query_url_here_options(query, reverse_geocode)
      options = {
        gen: 9,
        apikey: configuration.api_key,
        language: (query.language || configuration.language)
      }
      if reverse_geocode
        options[:mode] = :retrieveAddresses
        return options
      end

      unless (country = query.options[:country]).nil?
        options[:country] = country
      end

      unless (mapview = query.options[:bounds]).nil?
        options[:mapview] = mapview.map{ |point| "%f,%f" % point }.join(';')
      end
      options
    end

    def query_url_params(query)
      if query.reverse_geocode?
        super.merge(query_url_here_options(query, true)).merge(
          prox: query.sanitized_text
        )
      else
        super.merge(query_url_here_options(query, false)).merge(
          searchtext: query.sanitized_text
        )
      end
    end
  end
end
