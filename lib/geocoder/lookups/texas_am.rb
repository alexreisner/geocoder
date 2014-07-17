require 'geocoder/lookups/base'
require "geocoder/results/texas_am"

# Need this gem for XML support
require "nokogiri"

# TODO can't use this gems?
# require 'active_support/all'

module Geocoder::Lookup

  # Copied from stackoverflow and https://gist.github.com/huy/819999. Used to avoid active_support. If you wish to use
  # active_support instead then uncomment the active_support require statement above and the line in the parse_xml '
  # method below. This extension of Hash would then become unnecessary.
  class Hash
    class << self
      def from_xml(xml_io)
        begin
          result = Nokogiri::XML(xml_io)
          return { result.root.name => xml_node_to_hash(result.root)}
        rescue Exception => e
          # raise your custom exception here
        end
      end

      def xml_node_to_hash(node)
        # If we are at the root of the document, start the hash
        if node.element?
          result_hash = {}
          if node.attributes != {}
            attributes = {}
            node.attributes.keys.each do |key|
              attributes[node.attributes[key].name] = node.attributes[key].value
            end
          end
          if node.children.size > 0
            node.children.each do |child|
              result = xml_node_to_hash(child)

              if child.name == 'text'
                unless child.next_sibling || child.previous_sibling
                  return result unless attributes
                  result_hash[child.name] = result
                end
              elsif result_hash[child.name]

                if result_hash[child.name].is_a?(Object::Array)
                  result_hash[child.name] << result
                else
                  result_hash[child.name] = [result_hash[child.name]] << result
                end
              else
                result_hash[child.name] = result
              end
            end
            if attributes
              #add code to remove non-data attributes e.g. xml schema, namespace here
              #if there is a collision then node content supersets attributes
              result_hash = attributes.merge(result_hash)
            end
            return result_hash
          else
            return attributes
          end
        else
          return node.content.to_s
        end
      end
    end
  end

  class TexasAm < Base

    def name
      'Texas A&M'
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

    ##
    # Construct hash for query arguments from raw string input
    #
    # @param  query - the sanitized input query. Expects form: "street address, city, state, zip"
    #                 it's okay if one or more of these parameters are missing so long as the query
    #                 string has 3 commas. For instance: ",,,20008" is a valid query.
    #
    def query_url_params(query)

      # Store the clean query by sanitizing the query text
      clean_query = query.sanitized_text()

      # Base parameters for both lookup cases
      params = {
          :apiKey => configuration.api_key,
          :version => configuration.version || 4.01
      }.merge(super)

      if query.reverse_geocode?  # Case for lookup by longitude/latitude
        # break latitude/longitude into parts. TODO figure out malformed cases????
        split = clean_query.split(/,|\p{Blank}/)
        params.merge!({
          :lat => split[0].strip,
          :lon => split[1].strip,
          :format => configuration.format_reverse || 'JSON'
        })
      else # Case for lookup by address
        # break full address into parts. TODO figure out malformed cases?
        split = clean_query.split(',')
        params.merge!({
          :streetAddress => split[0].strip,
          :city => split[1].strip,
          :state => split[2].strip,
          :zip => split[3].strip,
          :format => configuration.format_forward || 'XML'
        })
      end
      return params
    end

    ##
    # Parse XML data into a ruby hash
    #
    # @param  data    string data in CSV form to be parsed into a Ruby hash
    # @return {Hash}  results returned from query to API as hash
    #
    def parse_csv(data)
      # TODO to be implemented?
    end

    ##
    # Parse XML data into a ruby hash
    #
    # @param  data    string data in XML form to be parsed into a Ruby hash
    # @return {Hash}  results returned from query to API as Ruby hash
    #
    def parse_xml(data)
      if defined? (Nokogiri::XML)
        # Hash.from_xml(Nokogiri::XML(data).to_xml), TODO uncomment if using active_support okay...
        Hash.from_xml(data)
      else
        'Nokogiri not loaded. You need an XML parser as Texas A&M does not offer JSON.'
      end
    end

    ##
    # Intermediate method that calls the parser for the raw data returned from the API request
    #
    # @param  raw_data  raw string data returned from API call
    # @return {Hash}    results from the parse_json or parse_xml method
    #
    # ^Override
    def parse_raw_data(raw_data, reversed_geocode)
      begin
        return reversed_geocode ? parse_json(raw_data) : parse_xml(raw_data)
      rescue
        raise_error(Geocoder::InvalidRequest) || warn("Geocoding API's response was not valid XML/JSON.")
      end
    end

    ##
    # Returns a parsed search result (Ruby hash).
    #
    # @param query            - the geocode query
    # @param reversed_geocode - boolean denoting whether query is a reverse lookup
    #
    # ^Override
    def fetch_data(query, reversed_geocode)
      parse_raw_data(fetch_raw_data(query), reversed_geocode)
    rescue SocketError => err
      raise_error(err) or warn 'Geocoding API connection cannot be established.'
    rescue TimeoutError => err
      raise_error(err) or warn 'Geocoding API not responding fast enough  (use Geocoder.configure(:timeout => ...) to set limit).'
    end

    ##
    # Constructs hash for results
    #
    # @param query - the geocode query
    #
    def results(query)
      reversed_geocode = query.reverse_geocode?
      return [] unless doc = fetch_data(query, reversed_geocode)
      # Texas A&M has different APIs for lookup vs reverse lookup. At the time of writing this code, the lookup only
      # offers return types of XML and CSV while the reverse lookup offers JSON. This ugly mess below handles both
      # cases and populates a single standard hash to return as a result hash.
      unihash = {}
      if reversed_geocode
        case doc['QueryStatusCode']
          when 'Success'
            latlong = query.sanitized_text.split(',')
            unihash['lat'] = latlong[0].strip
            unihash['lon'] = latlong[1].strip
            unihash['streetaddr'] = doc['StreetAddresses'][0]['StreetAddress']
            unihash['city'] = doc['StreetAddresses'][0]['City']
            unihash['state'] = doc['StreetAddresses'][0]['State']
            unihash['zip'] = doc['StreetAddresses'][0]['Zip']
          else
            raise_error(Geocoder::RequestDenied) || warn('Texas A&M Geocoding API error: request denied')
          # TODO Handle other error cases...?
        end
      else
        case doc['WebServiceGeocodeResult']['QueryMetadata']['QueryStatusCodeValue']
          when '200'
            unihash['lat'] = doc['WebServiceGeocodeResult']['OutputGeocodes']['OutputGeocode']['Latitude']
            unihash['lon'] = doc['WebServiceGeocodeResult']['OutputGeocodes']['OutputGeocode']['Longitude']
            unihash['streetaddr'] =  doc['WebServiceGeocodeResult']['InputAddress']['StreetAddress']
            unihash['city'] = doc['WebServiceGeocodeResult']['InputAddress']['City']
            unihash['state'] = doc['WebServiceGeocodeResult']['InputAddress']['State']
            unihash['zip'] = doc['WebServiceGeocodeResult']['InputAddress']['Zip']
          when '470'
            raise_error(Geocoder::InvalidApiKey) || warn("Invalid Texas A&M API Key")
          else
            raise_error(Geocoder::RequestDenied) || warn('Texas A&M Geocoding API error: request denied')
          # TODO Handle other error cases...?
        end
      end
      return [unihash]
    end

  end

end
