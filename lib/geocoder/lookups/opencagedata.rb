require 'geocoder/lookups/base'
require 'geocoder/results/opencagedata'

module Geocoder::Lookup
  class Opencagedata < Base

    def name
      "OpenCageData"
    end

    def query_url(query)
      "#{protocol}://api.opencagedata.com/geocode/v1/json?key=#{configuration.api_key}&q=#{url_query_string(query)}"
    end

    def required_api_key_parts
      ["key"]
    end

    private

    def valid_response?(response)
      status = parse_json(response.body)["status"]
      super(response) and status['message'] == 'OK'
    end

    def results(query)
      data = fetch_data(query)
      (data && data['results']) || []
    end

    def query_url_params(query)
      params = {
        :query => query.sanitized_text,
        :language => (query.language || configuration.language)
      }.merge(super)

      unless (bounds = query.options[:bounds]).nil?
        params[:bounds] = bounds.map{ |point| "%f,%f" % point }.join(',')
      end

      params
    end

  end
end
