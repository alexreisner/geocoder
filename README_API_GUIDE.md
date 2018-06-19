Guide to Geocoding APIs
=======================

This is a list of geocoding APIs supported by the Geocoder gem. Before using any API in a production environment, please read its official Terms of Service (links below).

Table of Contents
-----------------

* [Street Address Lookups](#street-address-lookups)
* [IP Address Lookups](#ip-address-lookups)
* [Local IP Address Lookups](#local-ip-address-lookups)

Street Address Lookups
----------------------

### Google (`:google`)

* **API key**: optional, but quota is higher if key is used (use of key requires HTTPS so be sure to set: `use_https: true` in `Geocoder.configure`)
* **Key signup**: https://console.developers.google.com/flows/enableapi?apiid=geocoding_backend&keyType=SERVER_SIDE
* **Quota**: 2,500 requests/24 hrs, 5 requests/second
* **Region**: world
* **SSL support**: yes (required if key is used)
* **Languages**: see https://developers.google.com/maps/faq#languagesupport
* **Extra params**:
  * `:bounds` - pass SW and NE coordinates as an array of two arrays to bias results towards a viewport
  * `:google_place_id` - pass `true` if search query is a Google Place ID
* **Documentation**: https://developers.google.com/maps/documentation/geocoding/intro
* **Terms of Service**: http://code.google.com/apis/maps/terms.html#section_10_12
* **Limitations**: "You must not use or display the Content without a corresponding Google map, unless you are explicitly permitted to do so in the Maps APIs Documentation, or through written permission from Google." "You must not pre-fetch, cache, or store any Content, except that you may store: (i) limited amounts of Content for the purpose of improving the performance of your Maps API Implementation..."

### Google Maps API for Work (`:google_premier`)

Similar to `:google`, with the following differences:

* **API key**: required, plus client and channel (set `Geocoder.configure(lookup: :google_premier, api_key: [key, client, channel])`)
* **Key signup**: https://developers.google.com/maps/documentation/business/
* **Quota**: 100,000 requests/24 hrs, 10 requests/second

### Google Places Details (`:google_places_details`)

The [Google Places Details API](https://developers.google.com/places/documentation/details) is not, strictly speaking, a geocoding service. It accepts a Google `place_id` and returns address information, ratings and reviews. A `place_id` can be obtained from the Google Places Search lookup (`:google_places_search`) and should be passed to Geocoder as the first search argument: `Geocoder.search("ChIJhRwB-yFawokR5Phil-QQ3zM", lookup: :google_places_details)`.

* **API key**: required
* **Key signup**: https://code.google.com/apis/console/
* **Quota**: 1,000 request/day, 100,000 after credit card authentication
* **Region**: world
* **SSL support**: yes
* **Languages**: ar, eu, bg, bn, ca, cs, da, de, el, en, en-AU, en-GB, es, eu, fa, fi, fil, fr, gl, gu, hi, hr, hu, id, it, iw, ja, kn, ko, lt, lv, ml, mr, nl, no, pl, pt, pt-BR, pt-PT, ro, ru, sk, sl, sr, sv, tl, ta, te, th, tr, uk, vi, zh-CN, zh-TW (see http://spreadsheets.google.com/pub?key=p9pdwsai2hDMsLkXsoM05KQ&gid=1)
* **Documentation**: https://developers.google.com/places/documentation/details
* **Terms of Service**: https://developers.google.com/places/policies
* **Limitations**: "If your application displays Places API data on a page or view that does not also display a Google Map, you must show a "Powered by Google" logo with that data."

### Google Places Search (`:google_places_search`)

The [Google Places Search API](https://developers.google.com/places/web-service/search) is the geocoding service of Google Places API. It returns very limited location data, but it also returns a `place_id` which can be used with Google Place Details to get more detailed information. For a comparison between this and the regular Google Geocoding API, see https://maps-apis.googleblog.com/2016/11/address-geocoding-in-google-maps-apis.html

* Same specifications as Google Places Details (see above).

### Bing (`:bing`)

* **API key**: required (set `Geocoder.configure(lookup: :bing, api_key: key)`)
* **Key signup**: https://www.microsoft.com/maps/create-a-bing-maps-key.aspx
* **Quota**: 50,0000 requests/day (Windows app), 125,000 requests/year (non-Windows app)
* **Region**: world
* **SSL support**: no
* **Languages**: ?
* **Documentation**: http://msdn.microsoft.com/en-us/library/ff701715.aspx
* **Terms of Service**: http://www.microsoft.com/maps/product/terms.html
* **Limitations**: No country codes or state names. Must be used on "public-facing, non-password protected web sites," "in conjunction with Bing Maps or an application that integrates Bing Maps."

### Nominatim (`:nominatim`)

* **API key**: none
* **Quota**: 1 request/second
* **Region**: world
* **SSL support**: yes
* **Languages**: ?
* **Documentation**: http://wiki.openstreetmap.org/wiki/Nominatim
* **Terms of Service**: http://wiki.openstreetmap.org/wiki/Nominatim_usage_policy
* **Limitations**: Please limit request rate to 1 per second and include your contact information in User-Agent headers (eg: `Geocoder.configure(http_headers: { "User-Agent" => "your contact info" })`). [Data licensed under Open Database License (ODbL) (you must provide attribution).](http://www.openstreetmap.org/copyright)

### PickPoint (`:pickpoint`)

* **API key**: required
* **Key signup**: [https://pickpoint.io](https://pickpoint.io)
* **Quota**: 2500 requests / day for free non-commercial usage, commercial plans are [available](https://pickpoint.io/#pricing). No rate limit.
* **Region**: world
* **SSL support**: required
* **Languages**: worldwide
* **Documentation**: [https://pickpoint.io/api-reference](https://pickpoint.io/api-reference)
* **Limitations**: [Data licensed under Open Database License (ODbL) (you must provide attribution).](http://www.openstreetmap.org/copyright)


### LocationIQ (`:location_iq`)

* **API key**: required
* **Quota**: 60 requests/minute (2 req/sec, 10k req/day), then [ability to purchase more](http://locationiq.org/#pricing)
* **Region**: world
* **SSL support**: yes
* **Languages**: ?
* **Documentation**: https://locationiq.org/#docs
* **Terms of Service**: https://unwiredlabs.com/tos
* **Limitations**: [Data licensed under Open Database License (ODbL) (you must provide attribution).](https://www.openstreetmap.org/copyright)

### OpenCageData (`:opencagedata`)

* **API key**: required
* **Key signup**: https://opencagedata.com
* **Quota**: 2500 requests / day, then [ability to purchase more](https://opencagedata.com/pricing)
* **Region**: world
* **SSL support**: yes
* **Languages**: worldwide
* **Documentation**: https://opencagedata.com/api
* **Limitations**: [Data licensed under Open Database License (ODbL) (you must provide attribution).](http://www.openstreetmap.org/copyright)

### Yandex (`:yandex`)

* **API key**: optional, but without it lookup is territorially limited
* **Quota**: 25000 requests / day
* **Region**: world with API key, else restricted to Russia, Ukraine, Belarus, Kazakhstan, Georgia, Abkhazia, South Ossetia, Armenia, Azerbaijan, Moldova, Turkmenistan, Tajikistan, Uzbekistan, Kyrgyzstan and Turkey
* **SSL support**: HTTPS only
* **Languages**: Russian, Belarusian, Ukrainian, English, Turkish (only for maps of Turkey)
* **Documentation**: http://api.yandex.com.tr/maps/doc/intro/concepts/intro.xml
* **Terms of Service**: http://api.yandex.com.tr/maps/doc/intro/concepts/intro.xml#rules
* **Limitations**: ?

### Geocoder.ca (`:geocoder_ca`)

* **API key**: none
* **Quota**: ?
* **Region**: US and Canada
* **SSL support**: no
* **Languages**: English
* **Documentation**: ?
* **Terms of Service**: http://geocoder.ca/?terms=1
* **Limitations**: "Under no circumstances can our data be re-distributed or re-sold by anyone to other parties without our written permission."

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

### Here/Nokia (`:here`)

* **API key**: required (set `Geocoder.configure(api_key: [app_id, app_code])`)
* **Quota**: Depending on the API key
* **Region**: world
* **SSL support**: yes
* **Languages**: The preferred language of address elements in the result. Language code must be provided according to RFC 4647 standard.
* **Documentation**: http://developer.here.com/rest-apis/documentation/geocoder
* **Terms of Service**: http://developer.here.com/faqs#l&t
* **Limitations**: ?

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

### Mapzen (`:mapzen`)

* **API key**: required
* **Quota**: 25,000 free requests/month and [ability to purchase more](https://mapzen.com/pricing/)
* **Region**: world
* **SSL support**: yes
* **Languages**: en; see https://mapzen.com/documentation/search/language-codes/
* **Documentation**: https://mapzen.com/documentation/search/search/
* **Terms of Service**: http://mapzen.com/terms
* **Limitations**: [You must provide attribution](https://mapzen.com/rights/)
* **Notes**: Mapzen is the primary author of Pelias and offers Pelias-as-a-service in free and paid versions https://mapzen.com/pelias.

### Pelias (`:pelias`)

* **API key**: configurable (self-hosted service)
* **Quota**: none (self-hosted service)
* **Region**: world
* **SSL support**: yes
* **Languages**: en; see https://mapzen.com/documentation/search/language-codes/
* **Documentation**: http://pelias.io/
* **Terms of Service**: http://pelias.io/data_licenses.html
* **Limitations**: See terms
* **Notes**: Configure your self-hosted pelias with the `endpoint` option: `Geocoder.configure(lookup: :pelias, api_key: 'your_api_key', pelias: {endpoint: 'self.hosted/pelias'})`. Defaults to `localhost`.

### Data Science Toolkit (`:dstk`)

Data Science Toolkit provides an API whose response format is like Google's but which can be set up as a privately hosted service.

* **API key**: none
* **Quota**: No quota if you are self-hosting the service.
* **Region**: world
* **SSL support**: ?
* **Languages**: en
* **Documentation**: http://www.datasciencetoolkit.org/developerdocs
* **Terms of Service**: http://www.datasciencetoolkit.org/developerdocs#googlestylegeocoder
* **Limitations**: No reverse geocoding.
* **Notes**: If you are hosting your own DSTK server you will need to configure the host name, eg: `Geocoder.configure(lookup: :dstk, dstk: {host: "localhost:4567"})`.

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

### Geocodio (`:geocodio`)

* **API key**: required
* **Quota**: 2,500 free requests/day then purchase $0.0005 for each, also has volume pricing and plans.
* **Region**: US & Canada
* **SSL support**: yes
* **Languages**: en
* **Documentation**: https://geocod.io/docs/
* **Terms of Service**: https://geocod.io/terms-of-use/
* **Limitations**: No restrictions on use

### SmartyStreets (`:smarty_streets`)

* **API key**: requires auth_id and auth_token (set `Geocoder.configure(api_key: [id, token])`)
* **Quota**: 250/month then purchase at sliding scale.
* **Region**: US
* **SSL support**: yes (required)
* **Languages**: en
* **Documentation**: http://smartystreets.com/kb/liveaddress-api/rest-endpoint
* **Terms of Service**: http://smartystreets.com/legal/terms-of-service
* **Limitations**: No reverse geocoding.

### Geoportail.lu (`:geoportail_lu`)

* **API key**: none
* **Quota**: none
* **Region**: Luxembourg
* **SSL support**: yes
* **Languages**: en
* **Documentation**: http://wiki.geoportail.lu/doku.php?id=en:api
* **Terms of Service**: http://wiki.geoportail.lu/doku.php?id=en:mcg_1
* **Limitations**: ?

### Postcodes.io (`:postcodes_io`)

* **API key**: none
* **Quota**: ?
* **Region**: UK
* **SSL support**: yes
* **Languages**: English
* **Documentation**: http://postcodes.io/docs
* **Terms of Service**: ?
* **Limitations**: UK postcodes only

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

### LatLon.io (`:latlon`)

* **API key**: required
* **Quota**: Depends on the user's plan (free and paid plans available)
* **Region**: US
* **SSL support**: yes
* **Languages**: en
* **Documentation**: https://latlon.io/documentation
* **Terms of Service**: ?
* **Limitations**: No restrictions on use

### Base Adresse Nationale FR (`:ban_data_gouv_fr`)

* **API key**: none
* **Quota**: none
* **Region**: France
* **SSL support**: yes
* **Languages**: en / fr
* **Documentation**: https://adresse.data.gouv.fr/api/ (in french)
* **Terms of Service**: https://adresse.data.gouv.fr/faq/ (in french)
* **Limitations**: [Data licensed under Open Database License (ODbL) (you must provide attribution).](http://openstreetmap.fr/ban)

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


IP Address Lookups
------------------

### IPInfo.io (`:ipinfo_io`)

* **API key**: optional - see http://ipinfo.io/pricing
* **Quota**: 1,000/day - more with api key
* **Region**: world
* **SSL support**: no (not without access key - see http://ipinfo.io/pricing)
* **Languages**: English
* **Documentation**: http://ipinfo.io/developers
* **Terms of Service**: http://ipinfo.io/developers

### FreeGeoIP (`:freegeoip`) - [DISCONTINUED](https://github.com/alexreisner/geocoder/wiki/Freegeoip-Discontinuation)

* **API key**: none
* **Quota**: 15,000 requests per hour. After reaching the hourly quota, all of your requests will result in HTTP 403 (Forbidden) until it clears up on the next roll over.
* **Region**: world
* **SSL support**: no
* **Languages**: English
* **Documentation**: http://github.com/fiorix/freegeoip/blob/master/README.md
* **Terms of Service**: ?
* **Limitations**: ?
* **Notes**: If you are [running your own local instance of the FreeGeoIP service](https://github.com/fiorix/freegeoip) you can configure the host like this: `Geocoder.configure(freegeoip: {host: "..."})`.

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
* **Documentation**: https://market.mashape.com/fcambus/telize
* **Terms of Service**: ?
* **Limitations**: ?
* **Notes**: To use Telize set `Geocoder.configure(ip_lookup: :telize, api_key: "your_api_key")`. Or configure your self-hosted telize with the `host` option: `Geocoder.configure(ip_lookup: :telize, telize: {host: "localhost"})`.


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

### Ipstack (`:ipstack`)

* **API key**: required (see https://ipstack.com/product)
* **Quota**: 10,000 requests per month (with free API Key, 50,000/day and up for paid plans)
* **Region**: world
* **SSL support**: yes ( only with paid plan )
* **Languages**: English, German, Spanish, French, Japanese, Portugues (Brazil), Russian, Chinese
* **Documentation**: https://ipstack.com/documentation
* **Terms of Service**: ?
* **Limitations**: ?
* **Notes**: To use Ipstack set `Geocoder.configure(ip_lookup: :ipstack, api_key: "your_ipstack_api_key")`. Supports the optional params: `:hostname`, `:security`, `:fields`, `:language` (see API documentation for details).

### IP-API.com (`:ipapi_com`)

* **API key**: optional - see http://ip-api.com/docs/#usage_limits
* **Quota**: 150/minute - unlimited with api key
* **Region**: world
* **SSL support**: no (not without access key - see https://signup.ip-api.com/)
* **Languages**: English
* **Documentation**: http://ip-api.com/docs/
* **Terms of Service**: https://signup.ip-api.com/terms

### DB-IP.com (`:db_ip_com`)

* **API key**: required
* **Quota**: 2,500/day (with free API Key, 50,000/day and up for paid API keys)
* **Region**: world
* **SSL support**: yes (with paid API keys - see https://db-ip.com/api/)
* **Languages**: English (English with free API key, multiple languages with paid API keys)
* **Documentation**: https://db-ip.com/api/doc.php
* **Terms of Service**: https://db-ip.com/tos.php

### Ipdata.co (`:ipdata_co`)

* **API key**: optional, see: https://ipdata.co/pricing.html
* **Quota**: 1500/day (up to 600k with paid API keys)
* **Region**: world
* **SSL support**: yes
* **Languages**: English
* **Documentation**: https://ipdata.co/docs.html
* **Terms of Service**: https://ipdata.co/terms.html
* **Limitations**: ?


Local IP Address Lookups
------------------------

### MaxMind Local (`:maxmind_local`) - EXPERIMENTAL

This lookup provides methods for geocoding IP addresses without making a call to a remote API (improves speed and availability). It works, but support is new and should not be considered production-ready. Please [report any bugs](https://github.com/alexreisner/geocoder/issues) you encounter.

* **API key**: none (requires the GeoLite City database which can be downloaded from [MaxMind](http://dev.maxmind.com/geoip/legacy/geolite/))
* **Quota**: none
* **Region**: world
* **SSL support**: N/A
* **Languages**: English
* **Documentation**: http://www.maxmind.com/en/city
* **Terms of Service**: ?
* **Limitations**: ?
* **Notes**: There are two supported formats for MaxMind local data: binary file, and CSV file imported into an SQL database. **You must download a database from MaxMind and set either the `:file` or `:package` configuration option for local lookups to work.**

**To use a binary file** you must add the *geoip* (or *jgeoip* for JRuby) gem to your Gemfile or have it installed in your system, and specify the path of the MaxMind database in your configuration. For example:

    Geocoder.configure(ip_lookup: :maxmind_local, maxmind_local: {file: File.join('folder', 'GeoLiteCity.dat')})

**To use a CSV file** you must import it into an SQL database. The GeoLite *City* and *Country* packages are supported. Configure like so:

    Geocoder.configure(ip_lookup: :maxmind_local, maxmind_local: {package: :city})

You can generate ActiveRecord migrations and download and import data via provided rake tasks:

    # generate migration to create tables
    rails generate geocoder:maxmind:geolite_city

    # download, unpack, and import data
    rake geocoder:maxmind:geolite:load PACKAGE=city

You can replace `city` with `country` in any of the above tasks, generators, and configurations.

### GeoLite2 (`:geoip2`)

This lookup provides methods for geocoding IP addresses without making a call to a remote API (improves speed and availability). It works, but support is new and should not be considered production-ready. Please [report any bugs](https://github.com/alexreisner/geocoder/issues) you encounter.

* **API key**: none (requires a GeoIP2 or free GeoLite2 City or Country binary database which can be downloaded from [MaxMind](http://dev.maxmind.com/geoip/geoip2/))
* **Quota**: none
* **Region**: world
* **SSL support**: N/A
* **Languages**: English
* **Documentation**: http://www.maxmind.com/en/city
* **Terms of Service**: ?
* **Limitations**: ?
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


Copyright (c) 2009-18 Alex Reisner, released under the MIT license.
