require 'geocoder/results/base'

module Geocoder::Result
  class TrimbleMaps < Base
    # sample response:
    # https://singlesearch.alk.com/NA/api/search?query=Duluth MN
    #
    # {
    #     "Err": 0,
    #     "Locations": [
    #         {
    #             "Address": {
    #                 "StreetAddress": "",
    #                 "LocalArea": "",
    #                 "City": "Duluth",
    #                 "State": "MN",
    #                 "StateName": "Minnesota",
    #                 "Zip": "55806",
    #                 "County": "St. Louis",
    #                 "Country": "US",
    #                 "CountryFullName": "United States",
    #                 "SPLC": null
    #             },
    #             "Coords": {
    #                 "Lat": "46.776443",
    #                 "Lon": "-92.110529"
    #             },
    #             "Region": 4,
    #             "POITypeID": 0,
    #             "PersistentPOIID": -1,
    #             "SiteID": -1,
    #             "ResultType": 3,
    #             "ShortString": "Duluth, MN, US, St. Louis 55806",
    #             "TimeZone": "GMT-5:00 CDT"
    #         }
    #     ]
    # }

    def address(format = :unused)
      data["ShortString"]
    end

    def coordinates
      coords = data["Coords"] || {}
      [coords["Lat"].to_f, coords["Lon"].to_f]
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

