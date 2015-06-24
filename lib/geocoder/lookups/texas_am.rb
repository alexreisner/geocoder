require 'geocoder/lookups/base'
require "geocoder/results/texas_am"

module Geocoder::Lookup

  class TexasAm < Base

    def name
      'Texas A&M Geoservices'
    end

    def required_api_key_parts
      ['apiKey']
    end

    def query_url(query)
      if query.reverse_geocode?
        "#{protocol}://geoservices.tamu.edu/Services/ReverseGeocoding/WebService/v04_01/Rest/?" + url_query_string(query)
      else
        "#{protocol}://geoservices.tamu.edu/Services/Geocode/WebService/GeocoderWebServiceHttpNonParsed_V04_01.aspx?" + url_query_string(query)
      end
    end

    private # ---------------------------------------------------------------

    def query_url_params(query)

      # Store the clean query by sanitizing the query text
      clean_query = query.sanitized_text

      # Base parameters for both lookup cases
      params = {
          :apiKey => configuration.api_key,
          :version => 4.01,
          :format => 'JSON'
      }.merge(super)

      if query.reverse_geocode?
        split = clean_query.split(/,|\p{Blank}/)
        params.merge!({
                          :lat => split[0].strip,
                          :lon => split[1].strip
                      })
      else
        split = clean_query.split(',')
        params.merge!({
                          :streetAddress => split[0].strip,
                          :city => split[1].strip,
                          :state => split[2].strip,
                          :zip => split[3].strip
                      })
      end

      params
    end

    def fetch_data(query)
      begin
        parse_raw_data(fetch_raw_data(query))
      rescue SocketError => err
        raise_error(err) or warn 'Geocoding API connection cannot be established.'
      rescue TimeoutError => err
        raise_error(err) or warn 'Geocoding API not responding fast enough  (use Geocoder.configure(:timeout => ...) to set limit).'
      end
    end


    def results(query)
      return [] unless doc = fetch_data(query)

      if query.reverse_geocode?
        case doc['QueryStatusCode']
          when 'Success'
            return [doc]
          else
            raise_error(Geocoder::Error) || warn('Texas A&M Geocoding API error: unknown')
        end
      else
        case doc['QueryStatusCodeValue']
          when '200'
            return [doc]
          when '470'
            raise_error(Geocoder::InvalidApiKey) || warn("Invalid Texas A&M API Key")
          else
            raise_error(Geocoder::RequestDenied) || warn('Texas A&M Geocoding API error: request denied')
          # TODO Handle other error cases...?
        end
      end

      return []

    end

  end

end