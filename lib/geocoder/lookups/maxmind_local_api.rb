require 'geocoder/lookups/maxmind_local'
require 'geocoder/results/maxmind_local_api'

module Geocoder::Lookup
  class MaxmindLocalApi < Geocoder::Lookup.get(:maxmind_local).class #::Geocoder::Lookup::MaxmindLocal
    def name
      "MaxMind Local - API License Protected (since 2019/12) - limited for city package"
    end

    def results(query)
      if (configuration[:package] || :city) == :city
        addr = IPAddr.new(query.text).to_i

        q = %{
          SELECT l.country_name,
                 l.subdivision_1_name,
                 l.city_name,
                 b.latitude,
                 b.longitude
            FROM maxmind_geolite_city_location AS l
            LEFT JOIN maxmind_geolite_city_blocks AS b
              ON    l.geoname_id = b.geoname_id
                AND l.locale_code = "#{configuration[:preferred_language] || 'en'}"
           WHERE b.start_ip_num <= #{addr} AND #{addr} <= b.end_ip_num
        }

        format_result(q, [:country_name, :region_name, :city_name, :latitude, :longitude])
      else
        super(query)
      end
    end
  end
end
