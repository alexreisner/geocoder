require 'geocoder/lookups/base'
require 'geocoder/results/amazon'
require 'awesome_print'
require 'binding_of_caller'
require 'pry'

module Geocoder::Lookup
  class Amazon < Base
    def results(query)
      query.options[:index_name] = 'demo-geoloc'
      resp = client.search_place_index_for_text({ text: query.text, **query.options })
      # binding.pry
      resp.results.map(&:place)
    end

    private

    def client
      require_sdk
      @client ||= Aws::LocationService::Client.new
    end

    def require_sdk
      begin
        require 'aws-sdk-locationservice'
      rescue LoadError
        raise_error(Geocoder::ConfigurationError) ||
          Geocoder.log(
            :error,
            "Couldn't load the Amazon Location Service SDK. " +
            "Install it with: gem install aws-sdk-locationservice -v '~> 1.4'"
          )
      end
    end
  end
end
