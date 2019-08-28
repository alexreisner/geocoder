require 'geocoder/results/base'

module Geocoder::Result
    class MapKit < Base

        def address
            address_components_of_type(:full_address_line)
        end

        def city
            address_components_of_type(:city)
        end

        def state
            ""
        end

        def state_code
            ""
        end

        def country
            address_components_of_type(:country)
        end

        def country_code
            address_components_of_type(:country_code)
        end

        def postal_code
            address_components_of_type(:postal_code)
        end

        def coordinates
            [address_components_of_type(:lat), address_components_of_type(:lng)]
        end


        ##
        # Get address components of a given type.
        #
        #   :street_number
        #   :city
        #   :postal_code
        #   :country
        #   :country_code
        #   :full_address_line
        #   :lat
        #   :lng
        #
        def address_components_of_type(type)
            address_components[type.to_sym]
        end

        # TODO: Parsing of city names, the postal code and street numbers will work in germany only.
        def address_components
            # Return empty hash if something is not as expected.
            # Don't know whether we have to see geocodeAccuracy == ADDRESS_PARCEL but I'm very cautious here..
            if data[1].blank? || data[1][0].blank? || data[1][0]["formattedAddressLines"].blank?
                return {}
            end


            formatted_address = data[1][0]["formattedAddressLines"]

            {
                :street             => formatted_address[0].split(" ").first,
                :street_number      => formatted_address[0].split(" ").last,
                :city               => formatted_address[1].split(" ").last,
                :postal_code        => formatted_address[1].split(" ").first,
                :country            => data[1][0]["country"],
                :country_code       => data[1][0]["countryCode"],
                :full_address_line  => formatted_address.join(","),
                :lat                => data[1][0]["center"]["lat"],
                :lng                => data[1][0]["center"]["lng"]
            }
        end


    end
end
