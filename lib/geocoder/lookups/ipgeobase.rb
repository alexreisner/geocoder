require "rexml/document"
require 'iconv' unless String.instance_methods.include?(:encode)

require "#{File.dirname(__FILE__)}/base"
require "#{File.dirname(__FILE__)}/../results/ipgeobase"

module Geocoder::Lookup
  class Ipgeobase < Base

    def name
      "IpGeoBase"
    end

    def query_url(query)
      "http://ipgeobase.ru:7020/geo?#{url_query_string(query)}"
    end

    private # ---------------------------------------------------------------

    def parse_raw_data(raw_data)
      encoded_data = if raw_data.respond_to?(:encode)
        raw_data.encode('windows-1251', 'utf-8')
      else
        Iconv.iconv('windows-1251', 'utf-8', raw_data).first
      end

      if encoded_data.match(/Incorrect request|Not found/)
        return nil
      else        
        ip = REXML::Document.new(encoded_data).elements['ip-answer/ip']
              
        result = ip.elements.reduce({}){ |h, el| h[el.name] = el.text; h }
        result['ip'] = ip.attributes['value']

        result
      end
    end

    def results(query)      
      return [reserved_result(query.text)] if query.loopback_ip_address?

      begin
        return (doc = fetch_data(query)) ? [doc] : []
      rescue StandardError => err                
        raise_error(err)
        return []
      end
    end

    def reserved_result(ip)
      {
        'inetnum'     => "#{ip} - #{ip}",
        'ip'          => ip,
        'country'     => 'RU',
        'city'        => '',
        'district'    => '',       
        "lat"         => '0',
        "lng"         => '0'
      }
    end

    def query_url_params(query)
      {
        :ip => query.sanitized_text        
      }
    end
  end
end