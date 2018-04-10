require 'geocoder/lookups/base'
require 'geocoder/results/postcodes_io'

module Geocoder::Lookup
  class PostcodesIo < Base
    def name
      'Postcodes.io'
    end

    def query_url(query)
      str = query.sanitized_text.gsub(/\s/, '')
      format('%s://%s/%s', protocol, 'api.postcodes.io/postcodes', str)
    end

    def supported_protocols
      [:https]
    end

    private

    def results(query)
      response = fetch_data(query)
      return [] if response.nil? || response['status'] != 200 || response.empty?

      [response['result']]
    end
  end
end
