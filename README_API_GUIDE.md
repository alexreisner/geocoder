Guide to Geocoding APIs
=======================

This is a list of geocoding APIs supported by the Geocoder gem. Before using any API in a production environment, please read its official Terms of Service (links below).

Table of Contents
-----------------

* [Global Street Address Lookups](#global-street-address-lookups)
* [Regional Street Address Lookups](#regional-street-address-lookups)
* [IP Address Lookups](#ip-address-lookups)
* [Local IP Address Lookups](#local-ip-address-lookups)

Global Street Address Lookups
-----------------------------

### Amazon Location Service (`:amazon_location_service`)

* **API key**: required
* **Key signup**: https://console.aws.amazon.com/location
* **Quota**: pay-as-you-go pricing; 50 requests/second
* **Region**: world
* **SSL support**: yes, required
* **Languages**: en
* **Required params**:
  * `:index_name` - the name of the place index resource you want to use for the search
* **Extra params**:
  * `:max_results` - return at most this many results
* **Extra params** when geocoding (not reverse geocoding):
    * `:bias_position` - bias the results toward a given point, defined as `[latitude, longitude]`
    * `:filter_b_box` - a bounding box that you specify to filter your results to coordinates within the box's boundaries, defined as `[longitude_sw, latitude_sw, longitude_ne, latitude_ne]`
    * `:filter_countries` - an array of countries you want to geocode within, named by [ISO 3166 country codes](https://www.iso.org/iso-3166-country-codes.html), e.g. `['DEU', 'FRA']`
* **Documentation**: https://docs.aws.amazon.com/location
* **Terms of Service**: https://aws.amazon.com/service-terms
* **Limitations**: Caching is not supported.
* **Notes**:
  * You must install either the `aws-sdk` or `aws-sdk-locationservice` gem, version 1.4.0 or greater.
  * You can set a default index name for all queries in the Geocoder configuration:
    ```rb
      Geocoder.configure(
        lookup: :amazon_location_service,
        amazon_location_service: {
          index_name: 'YOUR_INDEX_NAME_GOES_HERE',
        }
      )
    ```
  * You can provide credentials to the AWS SDK in multiple ways:
    * Directly via the `api_key` parameter in the geocoder configuration:
      ```rb
        Geocoder.configure(
          lookup: :amazon_location_service,
          amazon_location_service: {
            index_name: 'YOUR_INDEX_NAME_GOES_HERE',
            api_key: {
              region: 'YOUR_INDEX_REGION',
              access_key_id: 'YOUR_AWS_ACCESS_KEY_ID_GOES_HERE',
              secret_access_key: 'YOUR_AWS_SECRET_ACCESS_KEY_GOES_HERE',
            }
          }
        )
      ```
    * Via environment variables and other external methods. See **Setting AWS Credentials** in the [AWS SDK for Ruby Developer Guide](https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html).

### Azure (`:azure`)

* **API key**: required
* **Key signup**: https://azure.microsoft.com/en-us/products/azure-maps
* **Quota**: 5,000 request/month with free API key, more with paid keys (see https://azure.microsoft.com/en-us/pricing/details/azure-maps)
* **Region**: world
* **SSL support**: yes
* **Languages**: see https://learn.microsoft.com/en-us/azure/azure-maps/supported-languages
* **Documentation**: https://learn.microsoft.com/en-us/azure/azure-maps
* **Terms of Service**: https://azure.microsoft.com/en-us/support/legal
* **Limitations**: Azure Maps doesn't have any maximum daily limits on the number of requests that can be made, however there are limits to the maximum number of queries per second (QPS) (see https://learn.microsoft.com/en-us/azure/azure-maps/azure-maps-qps-rate-limits)
* **Notes**: To limit the number of results returned, use `Geocoder.configure(lookup: :azure, api_key: "your_api_key", azure: { limit: your_limit })` (default 10).

### Bing (`:bing`)

* **API key**: required (set `Geocoder.configure(lookup: :bing, api_key: key)`)
* **Key signup**: https://www.microsoft.com/maps/create-a-bing-maps-key.aspx
* **Quota**: 50,0000 requests/day (Windows app), 125,000 requests/year (non-Windows app)
* **Region**: world
* **SSL support**: no
* **Languages**: The preferred language of address elements in the result. Language code must be provided according to RFC 4647 standard.
* **Documentation**: http://msdn.microsoft.com/en-us/library/ff701715.aspx
* **Terms of Service**: http://www.microsoft.com/maps/product/terms.html
* **Limitations**: No country codes or state names. Must be used on "public-facing, non-password protected web sites," "in conjunction with Bing Maps or an application that integrates Bing Maps."

### ESRI (`:esri`)

* **API key**: optional (set `Geocoder.configure(esri: {api_key: ["client_id", "client_secret"]})`)
* **Quota**: Required for some scenarios (see Terms of Service)
* **Region**: world
* **SSL support**: yes
* **Languages**: English
* **Documentation**: https://developers.arcgis.com/rest/geocode/api-reference/overview-world-geocoding-service.htm
* **Terms of Service**: http://www.esri.com/legal/software-license
* **Limitations**: Requires API key if results will be stored. Using API key will also remove rate limit.
* **Notes**: You can specify which projection you want to use by setting, for example: `Geocoder.configure(esri: {outSR: 102100})`. If you will store results, set the flag and provide API key: `Geocoder.configure(esri: {api_key: ["client_id", "client_secret"], for_storage: true})`. If you want to, you can also supply an ESRI token directly: `Geocoder.configure(esri: {token: Geocoder::EsriToken.new('TOKEN', Time.now + 1.day})`

### Geoapify (`:geoapify`)

* **API key**: required (set `Geocoder.configure(lookup: :geoapify, api_key: "your_api_key")`)
* **Key signup**: https://myprojects.geoapify.com/register
* **Quota**: 100,000/month with free API key, more with paid keys (see https://www.geoapify.com/api-pricing/)
* **Region**: world
* **SSL support**: yes
* **Languages**: The preferred language of address elements in the result. Language code must be provided according to ISO 639-1 2-character language codes.
* **Extra query options**:
    * `:limit` - restrict the maximum amount of returned results, e.g. `limit: 5`
    * `:autocomplete` - Use the automplete API, only when doing forward geocoding e.g. `autocomplete: true`
* **Extra params** (see [Geoapify documentation](https://apidocs.geoapify.com/docs/geocoding) for more information)
    * `:type` - restricts the type of the results, see API documentation for
      available types, e.g. `params: { type: 'amenity' }`
    * `:filter` - filters results by country, boundary or circle, e.g.
      `params: { filter: 'countrycode:de,es,fr' }`, see API documentation
      for available filters
    * `:bias` - a location bias based on which results are prioritized, e.g.
      `params: { bias: 'countrycode:de,es,fr' }`, see API documentation for
      available biases
* **Documentation**: https://apidocs.geoapify.com/docs/geocoding
* **Terms of Service**: https://www.geoapify.com/term-and-conditions/
* **Limitations**: When using the free plan for a commercial product, a link back is required (see https://www.geoapify.com/geocoding-api/). Rate limit (requests/second) applied based on pricing plan. [Data licensed under Open Database License (ODbL) (you must provide attribution).](https://www.openstreetmap.org/copyright)
* **Notes**: To use Geoapify, set `Geocoder.configure(lookup: :geoapify, api_key: "your_api_key")`.

### Google (`:google`)

* **API key**: required
* **Key signup**: https://developers.google.com/maps/documentation/geocoding/usage-and-billing
* **Quota**: pay-as-you-go pricing; 50 requests/second
* **Region**: world
* **SSL support**: yes (required if key is used)
* **Languages**: see https://developers.google.com/maps/faq#languagesupport
* **Extra params**:
  * `:bounds` - pass SW and NE coordinates as an array of two arrays to bias results towards a viewport
  * `:google_place_id` - pass `true` if search query is a Google Place ID
* **Documentation**: https://developers.google.com/maps/documentation/geocoding/intro
* **Terms of Service**: http://code.google.com/apis/maps/terms.html#section_10_12
* **Limitations**: "You can display Geocoding API results on a Google Map, or without a map. If you want to display Geocoding API results on a map, then these results must be displayed on a Google Map. ... If your application displays data from the Geocoding API on a page or view that does not also display a Google Map, you must show a Powered by Google logo with that data. ... ...you must not pre-fetch, index, store, or cache any Content except under the limited conditions stated in the terms." (see: https://developers.google.com/maps/documentation/geocoding/policies)

### Google Maps API for Work (`:google_premier`)

Similar to `:google`, with the following differences:

* **API key**: required, plus client and channel (set `Geocoder.configure(lookup: :google_premier, api_key: [key, client, channel])`)
* **Key signup**: https://developers.google.com/maps/premium/
* **Quota**: 100,000 requests/24 hrs, 10 requests/second

### Google Places Details (`:google_places_details`)

The [Google Places Details API](https://developers.google.com/maps/documentation/places/web-service/details) is not, strictly speaking, a geocoding service. It accepts a Google `place_id` and returns address information, ratings and reviews. A `place_id` can be obtained from the Google Places Search lookup (`:google_places_search`) and should be passed to Geocoder as the first search argument: `Geocoder.search("ChIJhRwB-yFawokR5Phil-QQ3zM", lookup: :google_places_details)`.

* **API key**: required
* **Key signup**: https://code.google.com/apis/console/
* **Quota**: 1,000 request/day, 100,000 after credit card authentication
* **Region**: world
* **SSL support**: yes
* **Languages**: ar, eu, bg, bn, ca, cs, da, de, el, en, en-AU, en-GB, es, eu, fa, fi, fil, fr, gl, gu, hi, hr, hu, id, it, iw, ja, kn, ko, lt, lv, ml, mr, nl, no, pl, pt, pt-BR, pt-PT, ro, ru, sk, sl, sr, sv, tl, ta, te, th, tr, uk, vi, zh-CN, zh-TW (see http://spreadsheets.google.com/pub?key=p9pdwsai2hDMsLkXsoM05KQ&gid=1)
* **Extra params**:
  * `:fields` - Requested API response fields (affects pricing, see the [Google Places Details developer guide](https://developers.google.com/maps/documentation/places/web-service/details#fields) for available fields)
* **Documentation**: https://developers.google.com/maps/documentation/places/web-service/details
* **Terms of Service**: https://developers.google.com/maps/documentation/places/web-service/policies
* **Limitations**: "If your application displays Places API data on a page or view that does not also display a Google Map, you must show a "Powered by Google" logo with that data."
* **Notes**:
  * You can set the default fields for all queries in the Geocoder configuration, for example:
    ```rb
    Geocoder.configure(
      google_places_details: {
        fields: %w[business_status formatted_address geometry name photos place_id plus_code types]
      }
    )
    ```

### Google Places Search (`:google_places_search`)

The [Google Places Search API](https://developers.google.com/maps/documentation/places/web-service/search) is the geocoding service of Google Places API. It returns very limited location data, but it also returns a `place_id` which can be used with Google Place Details to get more detailed information. For a comparison between this and the regular Google Geocoding API, see https://maps-apis.googleblog.com/2016/11/address-geocoding-in-google-maps-apis.html

* **API key**: required
* **Key signup**: https://code.google.com/apis/console/
* **Quota**: 1,000 request/day, 100,000 after credit card authentication
* **Region**: world
* **SSL support**: yes
* **Languages**: ar, eu, bg, bn, ca, cs, da, de, el, en, en-AU, en-GB, es, eu, fa, fi, fil, fr, gl, gu, hi, hr, hu, id, it, iw, ja, kn, ko, lt, lv, ml, mr, nl, no, pl, pt, pt-BR, pt-PT, ro, ru, sk, sl, sr, sv, tl, ta, te, th, tr, uk, vi, zh-CN, zh-TW (see http://spreadsheets.google.com/pub?key=p9pdwsai2hDMsLkXsoM05KQ&gid=1)
* **Extra params**:
  * `:fields` - requested API response fields (affects pricing, see the [source](https://github.com/alexreisner/geocoder/blob/master/lib/geocoder/lookups/google_places_search.rb) for available fields)
  * `:locationbias` - bias towards results in or near a specified area, using a string in one of the formats specified in the [API documentation](https://developers.google.com/maps/documentation/places/web-service/search-find-place#locationbias), e.g., `locationbias: "point:-36.8509,174.7645"`
* **Documentation**: https://developers.google.com/maps/documentation/places/web-service/search
* **Terms of Service**: https://developers.google.com/maps/documentation/places/web-service/policies
* **Limitations**: "If your application displays Places API data on a page or view that does not also display a Google Map, you must show a "Powered by Google" logo with that data."
* **Notes**:
  * You can set the default fields and/or location bias for all queries in the Geocoder configuration, for example:
    ```rb
    Geocoder.configure(
      google_places_search: {
        fields: %w[address_components adr_address business_status formatted_address geometry name
            photos place_id plus_code types url utc_offset vicinity],
        locationbias: "point:-36.8509,174.7645"
      }
    )
    ```

### Here/Nokia (`:here`)

* **API key**: required
* **Quota**: Depending on the API key
* **Region**: world
* **SSL support**: yes
* **Languages**: The preferred language of address elements in the result. Language code must be provided according to RFC 4647 standard.
* **Extra params**:
  * `:country` - pass the country or list of countries using the country code (3 bytes, ISO 3166-1-alpha-3) or the country name, to filter the results
* **Documentation**: https://developer.here.com/documentation/geocoding-search-api/dev_guide/topics/endpoint-geocode-brief.html
* **Terms of Service**: https://developer.here.com/terms-and-conditions
* **Limitations**: ?

### LocationIQ (`:location_iq`)

* **API key**: required
* **Quota**: 60 requests/minute (2 req/sec, 10k req/day), then [ability to purchase more](http://locationiq.com/pricing)
* **Region**: world
* **SSL support**: yes
* **Languages**: ?
* **Documentation**: https://locationiq.com/docs
* **Terms of Service**: https://unwiredlabs.com/tos
* **Limitations**: [Data licensed under Open Database License (ODbL) (you must provide attribution).](https://www.openstreetmap.org/copyright)

### Mapbox (`:mapbox`)

* **API key**: required
* **Dataset**: Uses `mapbox.places` dataset by default.  Specify the `mapbox.places-permanent` dataset by setting: `Geocoder.configure(mapbox: {dataset: "mapbox.places-permanent"})`
* **Key signup**: https://www.mapbox.com/pricing/
* **Quota**: depends on plan
* **Region**: complete coverage of US and Canada, partial coverage elsewhere (see for details: https://www.mapbox.com/developers/api/geocoding/#coverage)
* **SSL support**: yes
* **Languages**: English
* **Extra params** (see Mapbox docs for more):
    * `:country` - restrict results to a specific country, e.g., `us` or `ca`
    * `:types` - restrict results to categories such as `address`,
    `neighborhood`, `postcode`
    * `:proximity` - bias results toward a `lng,lat`, e.g.,
        `params: { proximity: "-84.0,42.5" }`
* **Documentation**: https://www.mapbox.com/developers/api/geocoding/
* **Terms of Service**: https://www.mapbox.com/tos/
* **Limitations**: For `mapbox.places` dataset, must be displayed on a Mapbox map; Cache results for up to 30 days. For `mapbox.places-permanent` dataset, depends on plan.
* **Notes**: Currently in public beta.

### Mapquest (`:mapquest`)

* **API key**: required
* **Key signup**: https://developer.mapquest.com/plans
* **Quota**: ?
* **HTTP Headers**: when using the licensed API you can specify a referer like so:
    `Geocoder.configure(http_headers: { "Referer" => "http://foo.com" })`
* **Region**: world
* **SSL support**: no
* **Languages**: English
* **Documentation**: http://www.mapquestapi.com/geocoding/
* **Terms of Service**: http://info.mapquest.com/terms-of-use/
* **Limitations**: ?
* **Notes**: You can use the open (non-licensed) API by setting: `Geocoder.configure(mapquest: {open: true})` (defaults to licensed version)

### Melissa Data (`:melissa_street`)

* **API key**: required
* **Key signup**: https://www.melissa.com/developer/
* **Quota**: ?
* **Region**: world
* **Languages**: English
* **Documentation**: https://www.melissa.com/developer/
* **Terms of Service**: https://www.melissa.com/terms
* **Limitations**: ?

### Nominatim (`:nominatim`)

* **API key**: none
* **Quota**: 1 request/second
* **Region**: world
* **SSL support**: yes
* **Languages**: ?
* **Documentation**: http://wiki.openstreetmap.org/wiki/Nominatim
* **Terms of Service**: https://operations.osmfoundation.org/policies/nominatim/
* **Limitations**: Please limit request rate to 1 per second and include your contact information in User-Agent headers (eg: `Geocoder.configure(http_headers: { "User-Agent" => "your contact info" })`). [Data licensed under Open Database License (ODbL) (you must provide attribution).](http://www.openstreetmap.org/copyright)

### OpenCageData (`:opencagedata`)

* **API key**: required
* **Key signup**: https://opencagedata.com
* **Quota**: 2500 requests / day, then [ability to purchase more](https://opencagedata.com/pricing)
* **Region**: world
* **SSL support**: yes
* **Languages**: worldwide
* **Documentation**: https://opencagedata.com/api
* **Limitations**: [Data licensed under Open Database License (ODbL) (you must provide attribution).](http://www.openstreetmap.org/copyright)

### OSM Names (`:osmnames`)

Open source geocoding engine which can be self-hosted. MapTiler.com hosts an installation for use with API key.

* **API key**: required if not self-hosting (see https://www.maptiler.com/cloud/plans/)
* **Quota**: none if self-hosting; 100,000/mo with MapTiler free plan (more with paid)
* **Region**: world
* **SSL support**: yes
* **Languages**: English
* **Documentation**: https://osmnames.org/ (open source project), https://cloud.maptiler.com/geocoding/ (MapTiler)
* **Terms of Service**: https://www.maptiler.com/terms/
* **Notes**: To use self-hosted service, set the `:host` option in `Geocoder.configure`.

### Pelias (`:pelias`)

Open source geocoding engine which can be self-hosted. There are multiple service providers that can host Pelias instances (see notes).

* **API key**: configurable (self-hosted service)
* **Quota**: none (self-hosted service)
* **Region**: world
* **SSL support**: yes
* **Languages**: en; see https://github.com/pelias/documentation/blob/master/language-codes.md
* **Extra params**: See [Pelias documentation](https://github.com/pelias/documentation/blob/master/search.md#available-search-parameters)
* **Documentation**: https://github.com/pelias/documentation/
* **Terms of Service**: https://github.com/pelias/documentation/blob/master/data-sources.md
* **Limitations**: See service provider terms
* **Notes**: Configure your self-hosted pelias with the `endpoint` option: `Geocoder.configure(lookup: :pelias, api_key: 'your_api_key', pelias: {endpoint: 'self.hosted/pelias'})`. Defaults to `localhost`.
    * [Geocode Earth](https://geocode.earth/cloud) - Cleared for Takeoff, Inc. (USA)
    * [Geoapify](https://www.geoapify.com/maps-geocoging-routing-on-premise-installations/) - Geoapify GmbH (Germany)

### Photon (`:photon`)

Open source geocoding engine which can be self-hosted. Komoot hosts a public installation for fair use without the need for an API key (usage might be subject of change).

* **API key**: none
* **Quota**: You can use the API for your project, but please be fair - extensive usage will be throttled.
* **Region**: world
* **SSL support**: yes
* **Languages**:  en, de, fr, it
* **Extra query options** (see [Photon documentation](https://github.com/komoot/photon) for more information):
    * `:limit` - restrict the maximum amount of returned results, e.g. `limit: 5`
    * `:filter` - extra filters for the search
        * `:bbox` (forward) - restricts the bounding box for the forward search,
          e.g. `filter: { bbox: [9.5, 51.5, 11.5, 53.5] }`
          (minLon, minLat, maxLon, maxLat).
        * `:osm_tag` (forward) - filters forward search results by
          [tags and values](https://taginfo.openstreetmap.org/projects/nominatim#tags),
          e.g. `filter: { osm_tag: 'tourism:museum' }`,
          see API documentation for more information.
        * `:string` (reverse) - filters the reverse search results by a query
          string filter, e.g. `filter: { string: 'query string filter' }`,
    * `:bias` (forward) - a location bias based on which results are
      prioritized, provide an option hash with the keys `:latitude`,
      `:longitude`, and `:scale` (optional, default scale: 1.6), e.g.
      `bias: { latitude: 12, longitude: 12, scale: 4 }`
    * `:radius` (reverse) - a kilometer radius for the reverse geocoding search,
      must be a positive number between 0-5000 (default radius: 1),
      e.g. `radius: 10`
    * `:distance_sort` (reverse) - defines if results are sorted by distance for
      reverse search queries or not, only available if the distance sorting is
      enabled for the instace, e.g. `distance_sort: true`
* **Documentation**: https://github.com/komoot/photon
* **Terms of Service**: https://photon.komoot.io/
* **Limitations**: The public API provider (Komoot) does not guarantee for the availability and usage might be subject of change in the future. You can host your own Photon server without such limitations. [Data licensed under Open Database License (ODbL) (you must provide attribution).](https://www.openstreetmap.org/copyright)
* **Notes**: If you are [running your own instance of Photon](https://github.com/komoot/photon) you can configure the host like this: `Geocoder.configure(lookup: :photon, photon: {host: "photon.example.org"})`.

### PickPoint (`:pickpoint`)

* **API key**: required
* **Key signup**: [https://pickpoint.io](https://pickpoint.io)
* **Quota**: 2500 requests / day for free non-commercial usage, commercial plans are [available](https://pickpoint.io/#pricing). No rate limit.
* **Region**: world
* **SSL support**: required
* **Languages**: worldwide
* **Documentation**: [https://pickpoint.io/api-reference](https://pickpoint.io/api-reference)
* **Limitations**: [Data licensed under Open Database License (ODbL) (you must provide attribution).](http://www.openstreetmap.org/copyright)

### PC Miler (Trimble) (`:pc_miler`)

PC Miler (aka Trimble) provides geocoding services especially tailored to the trucking / logistics industry.

* **API key**: required
* **Quota**: ?
* **Region**: world
* **SSL support**: yes
* **Languages**: en
* **Documentation**: https://developer.trimblemaps.com/restful-apis/location/single-search/single-search-api/
* **Terms of Service**: https://developer.trimblemaps.com/restful-apis/developer-guide/introduction/
* **Limitations**: ?
* **Notes**: A region (continent) must be specified in global config or per-query. Defaults to `NA` ('North America').


### Yandex (`:yandex`)

* **API key**: optional, but without it lookup is territorially limited
* **Quota**: 25000 requests / day
* **Region**: world with API key, else restricted to Russia, Ukraine, Belarus, Kazakhstan, Georgia, Abkhazia, South Ossetia, Armenia, Azerbaijan, Moldova, Turkmenistan, Tajikistan, Uzbekistan, Kyrgyzstan and Turkey
* **SSL support**: HTTPS only
* **Languages**: Russian, Belarusian, Ukrainian, English, Turkish (only for maps of Turkey)
* **Documentation**: http://api.yandex.com.tr/maps/doc/intro/concepts/intro.xml
* **Terms of Service**: http://api.yandex.com.tr/maps/doc/intro/concepts/intro.xml#rules
* **Limitations**: ?


Regional Street Address Lookups
-------------------------------

### AMap (`:amap`)

- **API key**: required
- **Quota**: 2000/day and 2000/minute for personal developer, 4000000/day and 60000/minute for enterprise developer, for geocoding requests
- **Region**: China
- **SSL support**: yes
- **Languages**: Chinese (Simplified)
- **Documentation**: http://lbs.amap.com/api/webservice/guide/api/georegeo
- **Terms of Service**: http://lbs.amap.com/home/terms/
- **Limitations**: Only good for non-commercial use. For commercial usage please check http://lbs.amap.com/home/terms/
- **Notes**: To use AMap set `Geocoder.configure(lookup: :amap, api_key: "your_api_key")`.

### Baidu (`:baidu`)

* **API key**: required
* **Quota**: No quota limits for geocoding
* **Region**: China
* **SSL support**: no
* **Languages**: Chinese (Simplified)
* **Documentation**: http://developer.baidu.com/map/webservice-geocoding.htm
* **Terms of Service**: http://developer.baidu.com/map/law.htm
* **Limitations**: Only good for non-commercial use. For commercial usage please check http://developer.baidu.com/map/question.htm#qa0013
* **Notes**: To use Baidu set `Geocoder.configure(lookup: :baidu, api_key: "your_api_key")`.

### Base Adresse Nationale FR (`:ban_data_gouv_fr`)

* **API key**: none
* **Quota**: none
* **Region**: France
* **SSL support**: yes
* **Languages**: en / fr
* **Documentation**: https://adresse.data.gouv.fr/api-doc/adresse (in french)
* **Terms of Service**: https://doc.adresse.data.gouv.fr/ (in french)
* **Limitations**: [Data licensed under Open Database License (ODbL) (you must provide attribution).](http://openstreetmap.fr/ban)

### Geocoder.ca (`:geocoder_ca`)

* **API key**: none
* **Quota**: ?
* **Region**: US, Canada, Mexico
* **SSL support**: no
* **Languages**: English
* **Documentation**: https://geocoder.ca/?premium_api=1
* **Terms of Service**: http://geocoder.ca/?terms=1
* **Limitations**: "Under no circumstances can our data be re-distributed or re-sold by anyone to other parties without our written permission."

### Geocodio (`:geocodio`)

* **API key**: required
* **Quota**: 2,500 free requests/day then purchase $0.0005 for each, also has volume pricing and plans.
* **Region**: US & Canada
* **SSL support**: yes
* **Languages**: en
* **Documentation**: https://geocod.io/docs/
* **Terms of Service**: https://geocod.io/terms-of-use/
* **Limitations**: No restrictions on use

### Geoportail.lu (`:geoportail_lu`)

* **API key**: none
* **Quota**: none
* **Region**: Luxembourg
* **SSL support**: yes
* **Languages**: en
* **Documentation**: http://wiki.geoportail.lu/doku.php?id=en:api
* **Terms of Service**: http://wiki.geoportail.lu/doku.php?id=en:mcg_1
* **Limitations**: ?

### LatLon.io (`:latlon`)

* **API key**: required
* **Quota**: Depends on the user's plan (free and paid plans available)
* **Region**: US
* **SSL support**: yes
* **Languages**: en
* **Documentation**: https://latlon.io/documentation
* **Terms of Service**: ?
* **Limitations**: No restrictions on use

### Nationaal Georegister Netherlands (`:nationaal_georegister_nl`)

* **API key**: none
* **Quota**: none
* **Region**: Netherlands
* **SSL support**: yes
* **Languages**: Dutch
* **Documentation**: http://geodata.nationaalgeoregister.nl/
* **Terms of Service**: https://www.pdok.nl/over-pdok - The PDOK services are based on open data and are therefore freely available to everyone.

### pdok NL (`:pdok_nl`)

* **API key**: none
* **Quota**: none
* **Region**: Netherlands
* **SSL support**: yes, required
* **Languages**: Dutch
* **Documentation**: https://api.pdok.nl/bzk/locatieserver/search/v3_1/ui/#/Locatieserver/free
* **Terms of Service**: https://www.pdok.nl/over-pdok - The PDOK services are based on open data and are therefore freely available to everyone.

### Ordnance Survey OpenNames (`:uk_ordnance_survey_names`)

* **API key**: required (sign up at https://developer.ordnancesurvey.co.uk/os-names-api)
* **Quota**: 250,000 / month
* **Region**: England, Wales and Scotland
* **SSL support**: yes
* **Languages**: English
* **Documentation**: https://apidocs.os.uk/docs/os-names-overview
* **Terms of Service**: https://developer.ordnancesurvey.co.uk/os-api-framework-agreement
* **Limitations**: Only searches postcodes and placenames in England, Wales and Scotland

### PostcodeAnywhere UK (`:postcode_anywhere_uk`)

* **API key**: required
* **Quota**: Dependant on service plan?
* **Region**: UK
* **SSL support**: yes
* **Languages**: English
* **Documentation**: http://www.postcodeanywhere.co.uk/Support/WebService/Geocoding/UK/Geocode/2/
* **Terms of Service**: ?
* **Limitations**: ?
* **Notes**: To use PostcodeAnywhere you must include an API key: `Geocoder.configure(lookup: :postcode_anywhere_uk, api_key: 'your_api_key')`.

### SmartyStreets (`:smarty_streets`)

* **API key**: requires auth_id and auth_token (set `Geocoder.configure(api_key: [id, token])`)
* **Quota**: 250/month then purchase at sliding scale.
* **Region**: US
* **SSL support**: yes (required)
* **Languages**: en
* **Documentation**: http://smartystreets.com/kb/liveaddress-api/rest-endpoint
* **Terms of Service**: http://smartystreets.com/legal/terms-of-service
* **Limitations**: No reverse geocoding.

### Tencent (`:tencent`)

* **API key**: required
* **Key signup**: http://lbs.qq.com/console/mykey.html
* **Quota**: 10,000 free requests per day per key. 5 requests per second per key. For increased quota, one must first apply to become a corporate developer and then apply for increased quota.
* **Region**: China
* **SSL support**: yes
* **Languages**: Chinese (Simplified)
* **Documentation**: http://lbs.qq.com/webservice_v1/guide-geocoder.html (Standard) & http://lbs.qq.com/webservice_v1/guide-gcoder.html (Reverse)
* **Terms of Service**: http://lbs.qq.com/terms.html
* **Limitations**: Only works for locations in Greater China (mainland China, Hong Kong, Macau, and Taiwan).
* **Notes**: To use Tencent, set `Geocoder.configure(lookup: :tencent, api_key: "your_api_key")`.


IP Address Lookups
------------------

### Abstract API (`:abstract_api`)

* **API key**: required
* **Quota**: 20,000/day with free API Key, and un to 20,000,000/day for paid API keys
* **Region**: world
* **SSL support**: yes
* **Languages**: English
* **Documentation**: https://www.abstractapi.com/ip-geolocation-api#docs
* **Terms of Service**: https://www.abstractapi.com/legal

### Baidu IP (`:baidu_ip`)

* **API key**: required
* **Quota**: No quota limits for geocoding
* **Region**: China
* **SSL support**: no
* **Languages**: Chinese (Simplified)
* **Documentation**: http://developer.baidu.com/map/webservice-geocoding.htm
* **Terms of Service**: http://developer.baidu.com/map/law.htm
* **Limitations**: Only good for non-commercial use. For commercial usage please check http://developer.baidu.com/map/question.htm#qa0013
* **Notes**: To use Baidu set `Geocoder.configure(lookup: :baidu_ip, api_key: "your_api_key")`.

### DB-IP.com (`:db_ip_com`)

* **API key**: required
* **Quota**: 2,500/day (with free API Key, 50,000/day and up for paid API keys)
* **Region**: world
* **SSL support**: yes (with paid API keys - see https://db-ip.com/api/)
* **Languages**: English (English with free API key, multiple languages with paid API keys)
* **Documentation**: https://db-ip.com/api/doc.php
* **Terms of Service**: https://db-ip.com/tos.php

### FreeGeoIP (`:freegeoip`)

* **API key**: required
* **Quota**: 15,000 requests per hour
* **Region**: world
* **SSL support**: no
* **Languages**: English
* **Documentation**: https://github.com/apilayer/freegeoip/ and https://freegeoip.app/
* **Terms of Service**: ?
* **Limitations**: ?
* **Notes**: The default host is freegeoip.app but this can be changed by using, for example, `Geocoder.configure(freegeoip: {host: 'api.ipstack.com'})`. The service can also be self-hosted.

### IPBase (`:ipbase`)

* **API key**: required
* **Quota**: 10/minute up to 150 per month for free, paid plans too!
* **Region**: world
* **SSL support**: yes
* **Languages**: English
* **Documentation**: https://ipbase.com/docs
* **Terms of Service**: https://www.iubenda.com/terms-and-conditions/41661719

### IP-API.com (`:ipapi_com`)

* **API key**: optional - see https://members.ip-api.com
* **Quota**: 45/minute - unlimited with api key
* **Region**: world
* **SSL support**: no (not without access key - see https://members.ip-api.com)
* **Languages**: English
* **Documentation**: http://ip-api.com/docs/
* **Terms of Service**: https://members.ip-api.com/legal

### IP2Location (`:ip2location`)

* **API key**: required (5,000 free credits given on signup; free demo key available for 20 queries per day)
* **Quota**: up to 100k credits with paid API key
* **Region**: world
* **SSL support**: yes
* **Languages**: English
* **Documentation**: https://www.ip2location.com/web-service
* **Terms of Service**: https://www.ip2location.com/web-service
* **Notes**: With the non-free version, specify your desired package: `Geocoder.configure(ip2location: {package: "WSX"})` (see API documentation for package details).

### Ipdata.co (`:ipdata_co`)

* **API key**: required, see: https://ipdata.co/pricing.html
* **Quota**: 1500/day for free, up to 600k with paid API keys
* **Region**: world
* **SSL support**: yes
* **Languages**: English
* **Documentation**: https://ipdata.co/docs.html
* **Terms of Service**: https://ipdata.co/terms.html
* **Limitations**: ?

### Ipgeolocation (`:ipgeolocation`)

* **API key**: required (see https://ipgeolocation.io/pricing)
* **Quota**: 1500/day (with free API Key)
* **Region**: world
* **SSL support**: yes
* **Languages**: English, German, Russian, Japanese, French, Chinese, Spanish, Czech, Italian
* **Documentation**: https://ipgeolocation.io/documentation
* **Terms of Service**: https://ipgeolocation/tos
* **Notes**: To use Ipgeolocation set `Geocoder.configure(ip_lookup: :ipgeolocation, api_key: "your_ipgeolocation_api_key", use_https:true)`. Supports the optional params:  { excludes: "continent_code"}, {fields: "geo"}, {lang: "ru"}, {output: "xml"}, {include: "hostname"}, {ip: "174.7.116.0"}) (see API documentation for details).

### IPInfo.io (`:ipinfo_io`)

* **API key**: optional - see https://ipinfo.io/pricing
* **Quota**: 1,000/day without API key, 50,000/mo with a free account - more with a paid plan - see https://ipinfo.io/developers#rate-limits
* **Region**: world
* **SSL support**: yes
* **Languages**: English
* **Documentation**: https://ipinfo.io/developers
* **Terms of Service**: https://ipinfo.io/terms-of-service

### IPQualityScore (`:ipqualityscore`)

* **API key**: required - see https://www.ipqualityscore.com/free-ip-lookup-proxy-vpn-test
* **Quota**: 5,000/month with a free account - more with a paid plan - see https://www.ipqualityscore.com/plans
* **Region**: world
* **SSL support**: yes
* **Languages**: English
* **Documentation**: https://www.ipqualityscore.com/documentation/overview
* **Terms of Service**: https://www.ipqualityscore.com/terms-of-service

### Ipregistry (`:ipregistry`)

* **API key**: required (see https://ipregistry.co)
* **Quota**: first 100,000 requests are free, then you pay per request (see https://ipregistry.co/pricing)
* **Region**: world
* **SSL support**: yes
* **Languages**: English
* **Documentation**: https://ipregistry.co/docs
* **Terms of Service**: https://ipregistry.co/terms

### Ipstack (`:ipstack`)

* **API key**: required (see https://ipstack.com/product)
* **Quota**: 100 requests per month (with free API Key, 50,000/day and up for paid plans)
* **Region**: world
* **SSL support**: yes ( only with paid plan )
* **Languages**: English, German, Spanish, French, Japanese, Portugues (Brazil), Russian, Chinese
* **Documentation**: https://ipstack.com/documentation
* **Terms of Service**: ?
* **Limitations**: ?
* **Notes**: To use Ipstack set `Geocoder.configure(ip_lookup: :ipstack, api_key: "your_ipstack_api_key")`. Supports the optional params: `:hostname`, `:security`, `:fields`, `:language` (see API documentation for details).

### MaxMind Legacy Web Services (`:maxmind`)

* **API key**: required
* **Quota**: Request Packs can be purchased
* **Region**: world
* **SSL support**: yes
* **Languages**: English
* **Documentation**: http://dev.maxmind.com/geoip/legacy/web-services/
* **Terms of Service**: ?
* **Limitations**: ?
* **Notes**: You must specify which MaxMind service you are using in your configuration. For example: `Geocoder.configure(maxmind: {service: :omni})`.

### MaxMind GeoIP2 Precision Web Services (`:maxmind_geoip2`)

* **API key**: required
* **Quota**: Request Packs can be purchased
* **Region**: world
* **SSL support**: yes
* **Languages**: English
* **Documentation**: http://dev.maxmind.com/geoip/geoip2/web-services/
* **Terms of Service**: ?
* **Limitations**: ?
* **Notes**: You must specify which MaxMind service you are using in your configuration, and also basic authentication. For example: `Geocoder.configure(maxmind_geoip2: {service: :country, basic_auth: {user: '', password: ''}})`.

### Pointpin (`:pointpin`)

* **API key**: required
* **Quota**: 50,000/mo for €9 through 1m/mo for €49
* **Region**: world
* **SSL support**: yes
* **Languages**: English
* **Documentation**: https://pointp.in/docs/get-started
* **Terms of Service**: https://pointp.in/terms
* **Limitations**: ?
* **Notes**: To use Pointpin set `Geocoder.configure(ip_lookup: :pointpin, api_key: "your_pointpin_api_key")`.

### Telize (`:telize`)

* **API key**: required
* **Quota**: 1,000/day for $7/mo through 100,000/day for $100/mo
* **Region**: world
* **SSL support**: yes
* **Languages**: English
* **Documentation**: https://rapidapi.com/fcambus/api/telize
* **Terms of Service**: ?
* **Limitations**: ?
* **Notes**: To use Telize set `Geocoder.configure(ip_lookup: :telize, api_key: "your_api_key")`. Or configure your self-hosted telize with the `host` option: `Geocoder.configure(ip_lookup: :telize, telize: {host: "localhost"})`.

### 2GIS (`:twogis`)

* **API key**: required
* **Key signup**:
* **Quota**:
* **Region**:
* **SSL support**: required
* **Languages**: ru_RU, ru_KG, ru_UZ, uk_UA, en_AE, it_RU, es_RU, ar_AE, cs_CZ, az_AZ, en_SA, en_EG, en_OM, en_QA, en_BH
* **Documentation**: https://docs.2gis.com/en/api/search/geocoder/overview
* **Terms of Service**:
* **Limitations**:

### IP2Location.io (`:ip2location_io`)

* **API key**: required (30,000 free queries given on FREE plan)
* **Quota**: up to 600k queries with paid API key
* **Region**: world
* **SSL support**: yes
* **Languages**: English
* **Documentation**: https://www.ip2location.io/ip2location-documentation
* **Terms of Service**: https://www.ip2location.io/terms-of-service


Local IP Address Lookups
------------------------

### GeoLite2 (`:geoip2`)

This lookup provides methods for geocoding IP addresses without making a call to a remote API (improves speed and availability). It works, but support is new and should not be considered production-ready. Please [report any bugs](https://github.com/alexreisner/geocoder/issues) you encounter.

* **API key**: none (requires a GeoIP2 or free GeoLite2 City or Country binary database which can be downloaded from [MaxMind](http://dev.maxmind.com/geoip/geoip2/))
* **Quota**: none
* **Region**: world
* **SSL support**: N/A
* **Languages**: English
* **Documentation**: http://www.maxmind.com/en/city
* **Terms of Service**: ?
* **Limitations**: Caching is not supported.
* **Notes**: **You must download a binary database file from MaxMind and set the `:file` configuration option.** The CSV format databases are not yet supported since they are still in alpha stage. Set the path to the database file in your configuration:

    Geocoder.configure(
      ip_lookup: :geoip2,
      geoip2: {
        file: File.join('folder', 'GeoLite2-City.mmdb')
      }
    )

You must add either the *[hive_geoip2](https://rubygems.org/gems/hive_geoip2)* gem (native extension that relies on libmaxminddb) or the *[maxminddb](http://rubygems.org/gems/maxminddb)* gem (pure Ruby implementation) to your Gemfile or have it installed in your system. The pure Ruby gem (maxminddb) will be used by default. To use `hive_geoip2`:

    Geocoder.configure(
      ip_lookup: :geoip2,
      geoip2: {
        lib: 'hive_geoip2',
        file: File.join('folder', 'GeoLite2-City.mmdb')
      }
    )


### MaxMind Local (`:maxmind_local`) - EXPERIMENTAL

This lookup provides methods for geocoding IP addresses without making a call to a remote API (improves speed and availability). It works, but support is new and should not be considered production-ready. Please [report any bugs](https://github.com/alexreisner/geocoder/issues) you encounter.

* **API key**: none (requires the GeoLite City database which can be downloaded from [MaxMind](http://dev.maxmind.com/geoip/legacy/geolite/))
* **Quota**: none
* **Region**: world
* **SSL support**: N/A
* **Languages**: English
* **Documentation**: http://www.maxmind.com/en/city
* **Terms of Service**: ?
* **Limitations**: Caching is not supported.
* **Notes**: There are two supported formats for MaxMind local data: binary file, and CSV file imported into an SQL database. **You must download a database from MaxMind and set either the `:file` or `:package` configuration option for local lookups to work.**

**To use a binary file** you must add the *geoip* (or *jgeoip* for JRuby) gem to your Gemfile or have it installed in your system, and specify the path of the MaxMind database in your configuration. For example:

    Geocoder.configure(ip_lookup: :maxmind_local, maxmind_local: {file: File.join('folder', 'GeoLiteCity.dat')})

**To use a CSV file** you must import it into an SQL database. The GeoLite *City* and *Country* packages are supported. Configure like so:

    Geocoder.configure(ip_lookup: :maxmind_local, maxmind_local: {package: :city})

You can generate ActiveRecord migrations and download and import data via provided rake tasks:

    # generate migration to create tables
    rails generate geocoder:maxmind:geolite_city

    # download, unpack, and import data
    rake geocoder:maxmind:geolite:load PACKAGE=city LICENSE_KEY=<KEY>

You can replace `city` with `country` in any of the above tasks, generators, and configurations.

### IP2Location LITE (`:ip2location_lite`)

This lookup provides methods for geocoding IP addresses without making a call to a remote API (improves speed and availability).

* **API key**: none (requires a IP2Location or FREE IP2Location LITE binary database which can be downloaded from [IP2Location LITE](https://lite.ip2location.com/))
* **Quota**: none
* **Region**: world
* **SSL support**: N/A
* **Languages**: English
* **Documentation**: https://lite.ip2location.com/
* **Terms of Service**: https://lite.ip2location.com/
* **Notes**: **You must download a binary database (BIN) file from IP2Location LITE and set the `:file` configuration option.** Set the path to the database file in your configuration:

    Geocoder.configure(
      ip_lookup: :ip2location_lite,
      ip2location_lite: {
        file: File.join('folder', 'IP2LOCATION-LITE-DB11.BIN')
      }
    )

You must add the *[ip2location_ruby](https://rubygems.org/gems/ip2location_ruby)* gem (pure Ruby implementation) to your Gemfile or have it installed in your system.

Copyright (c) 2009-2021 Alex Reisner, released under the MIT license.
