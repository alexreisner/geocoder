require 'geocoder/results/base'

module Geocoder::Result
  class PcMiler < Base
    # sample response:
    # https://singlesearch.alk.com/na/api/search?authToken=<TOKEN>&include=Meta&query=Feasterville
    #
    #   {
    #     "Err": 0,
    #     "ErrString": "OK",
    #     "QueryConfidence": 1,
    #     "TimeInMilliseconds": 93,
    #     "GridDataVersion": "GRD_ALK.NA.2023.01.18.29.1.1",
    #     "CommitID": "pcmws-22.08.11.0-1778-g586da49bd1b: 05/30/2023 20:14",
    #     "Locations": [
    #       {
    #         "Address": {
    #           "StreetAddress": "",
    #           "LocalArea": "",
    #           "City": "Feasterville",
    #           "State": "PA",
    #           "StateName": "Pennsylvania",
    #           "Zip": "19053",
    #           "County": "Bucks",
    #           "Country": "US",
    #           "CountryFullName": "United States",
    #           "SPLC": null
    #         },
    #         "Coords": {
    #           "Lat": "40.150025",
    #           "Lon": "-75.002511"
    #         },
    #         "StreetCoords": {
    #           "Lat": "40.150098",
    #           "Lon": "-75.002827"
    #         },
    #         "Region": 4,
    #         "POITypeID": 0,
    #         "PersistentPOIID": -1,
    #         "SiteID": -1,
    #         "ResultType": 4,
    #         "ShortString": "Feasterville",
    #         "GridID": 37172748,
    #         "LinkID": 188,
    #         "Percent": 6291,
    #         "TimeZone": "GMT-4:00 EDT"
    #       }
    #     ]
    #   }

    def address(format=:unused)
      [street, city, state, postal_code, country]
      .map { |i| i == '' ? nil : i }
      .compact
      .join(', ')
    end

    def coordinates
      coords = data["Coords"] || {}
      [coords["Lat"].to_f, coords["Lon"].to_f]
    end

    def street
      address_data["StreetAddress"]
    end

    def city
      address_data["City"]
    end

    def state
      address_data["StateName"]
    end

    def state_code
      address_data["State"]
    end

    def postal_code
      address_data["Zip"]
    end

    def country
      address_data["CountryFullName"]
    end

    def country_code
      address_data["Country"]
    end

    private

    def address_data
      data["Address"] || {}
    end
  end
end

