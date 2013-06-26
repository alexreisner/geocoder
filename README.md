Geocoder
========

Geocoder is a complete geocoding solution for Ruby. With Rails it adds geocoding (by street or IP address), reverse geocoding (find street address based on given coordinates), and distance queries. It's as simple as calling `geocode` on your objects, and then using a scope like `Venue.near("Billings, MT")`.


Compatibility
-------------

* Supports multiple Ruby versions: Ruby 1.8.7, 1.9.2, 1.9.3, 2.0.0, and JRuby.
* Supports multiple databases: MySQL, PostgreSQL, SQLite, and MongoDB (1.7.0 and higher).
* Supports Rails 3 and 4. If you need to use it with Rails 2 please see the `rails2` branch (no longer maintained, limited feature set).
* Works very well outside of Rails, you just need to install either the `json` (for MRI) or `json_pure` (for JRuby) gem.


Installation
------------

Install Geocoder like any other Ruby gem:

    gem install geocoder

Or, if you're using Rails/Bundler, add this to your Gemfile:

    gem "geocoder"

and run at the command prompt:

    bundle install


Object Geocoding
----------------

### ActiveRecord

Your model must have two attributes (database columns) for storing latitude and longitude coordinates. By default they should be called `latitude` and `longitude` but this can be changed (see "Model Configuration" below):

    rails generate migration AddLatitudeAndLongitudeToModel latitude:float longitude:float
    rake db:migrate

For reverse geocoding your model must provide a method that returns an address. This can be a single attribute, but it can also be a method that returns a string assembled from different attributes (eg: `city`, `state`, and `country`).

Next, your model must tell Geocoder which method returns your object's geocodable address:

    geocoded_by :full_street_address   # can also be an IP address
    after_validation :geocode          # auto-fetch coordinates

For reverse geocoding, tell Geocoder which attributes store latitude and longitude:

    reverse_geocoded_by :latitude, :longitude
    after_validation :reverse_geocode  # auto-fetch address

### Mongoid

First, your model must have an array field for storing coordinates:

    field :coordinates, :type => Array

You may also want an address field, like this:

    field :address

but if you store address components (city, state, country, etc) in separate fields you can instead define a method called `address` that combines them into a single string which will be used to query the geocoding service.

Once your fields are defined, include the `Geocoder::Model::Mongoid` module and then call `geocoded_by`:

    include Geocoder::Model::Mongoid
    geocoded_by :address               # can also be an IP address
    after_validation :geocode          # auto-fetch coordinates

Reverse geocoding is similar:

    include Geocoder::Model::Mongoid
    reverse_geocoded_by :coordinates
    after_validation :reverse_geocode  # auto-fetch address

Once you've set up your model you'll need to create the necessary spatial indices in your database:

    rake db:mongoid:create_indexes

Be sure to read _Latitude/Longitude Order_ in the _Notes on MongoDB_ section below on how to properly retrieve latitude/longitude coordinates from your objects.

### MongoMapper

MongoMapper is very similar to Mongoid, just be sure to include `Geocoder::Model::MongoMapper`.

### Mongo Indices

By default, the methods `geocoded_by` and `reverse_geocoded_by` create a geospatial index. You can avoid index creation with the `:skip_index option`, for example:

    include Geocoder::Model::Mongoid
    geocoded_by :address, :skip_index => true

### Bulk Geocoding

If you have just added geocoding to an existing application with a lot of objects you can use this Rake task to geocode them all:

    rake geocode:all CLASS=YourModel

Geocoder will print warnings if you exceed the rate limit for your geocoding service.


Request Geocoding by IP Address
-------------------------------

Geocoder adds a `location` method to the standard `Rack::Request` object so you can easily look up the location of any HTTP request by IP address. For example, in a Rails controller or a Sinatra app:

    # returns Geocoder::Result object
    result = request.location

Note that this will usually return `nil` in your test and development environments because things like "localhost" and "0.0.0.0" are not an Internet IP addresses.

See _Advanced Geocoding_ below for more information about `Geocoder::Result` objects.


Location-Aware Database Queries
-------------------------------

To find objects by location, use the following scopes:

    Venue.near('Omaha, NE, US', 20)    # venues within 20 miles of Omaha
    Venue.near([40.71, 100.23], 20)    # venues within 20 miles of a point
    Venue.near([40.71, 100.23], 20, :units => :km)
                                       # venues within 20 kilometres of a point
    Venue.geocoded                     # venues with coordinates
    Venue.not_geocoded                 # venues without coordinates

With geocoded objects you can do things like this:

    if obj.geocoded?
      obj.nearbys(30)                      # other objects within 30 miles
      obj.distance_from([40.714,-100.234]) # distance from arbitrary point to object
      obj.bearing_to("Paris, France")      # direction from object to arbitrary point
    end

Some utility methods are also available:

    # look up coordinates of some location (like searching Google Maps)
    Geocoder.coordinates("25 Main St, Cooperstown, NY")
     => [42.700149, -74.922767]

    # distance (in miles) between Eiffel Tower and Empire State Building
    Geocoder::Calculations.distance_between([47.858205,2.294359], [40.748433,-73.985655])
     => 3619.77359999382

    # find the geographic center (aka center of gravity) of objects or points
    Geocoder::Calculations.geographic_center([city1, city2, [40.22,-73.99], city4])
     => [35.14968, -90.048929]

Please see the code for more methods and detailed information about arguments (eg, working with kilometers).


Distance and Bearing
--------------------

When you run a location-aware query the returned objects have two attributes added to them (only w/ ActiveRecord):

* `obj.distance` - number of miles from the search point to this object
* `obj.bearing` - direction from the search point to this object

Results are automatically sorted by distance from the search point, closest to farthest. Bearing is given as a number of clockwise degrees from due north, for example:

* `0` - due north
* `180` - due south
* `90` - due east
* `270` - due west
* `230.1` - southwest
* `359.9` - almost due north

You can convert these numbers to compass point names by using the utility method provided:

    Geocoder::Calculations.compass_point(355) # => "N"
    Geocoder::Calculations.compass_point(45)  # => "NE"
    Geocoder::Calculations.compass_point(208) # => "SW"

_Note: when using SQLite `distance` and `bearing` values are provided for interface consistency only. They are not very accurate._

To calculate accurate distance and bearing with SQLite or MongoDB:

    obj.distance_to([43.9,-98.6])  # distance from obj to point
    obj.bearing_to([43.9,-98.6])   # bearing from obj to point
    obj.bearing_from(obj2)         # bearing from obj2 to obj

The `bearing_from/to` methods take a single argument which can be: a `[lat,lon]` array, a geocoded object, or a geocodable address (string). The `distance_from/to` methods also take a units argument (`:mi`, `:km`, or `:nm` for nautical miles).


Model Configuration
-------------------

You are not stuck with using the `latitude` and `longitude` database column names (with ActiveRecord) or the `coordinates` array (Mongo) for storing coordinates. For example:

    geocoded_by :address, :latitude  => :lat, :longitude => :lon # ActiveRecord
    geocoded_by :address, :coordinates => :coords                # MongoDB

The `address` method can return any string you'd use to search Google Maps. For example, any of the following are acceptable:

* "714 Green St, Big Town, MO"
* "Eiffel Tower, Paris, FR"
* "Paris, TX, US"

If your model has `street`, `city`, `state`, and `country` attributes you might do something like this:

    geocoded_by :address

    def address
      [street, city, state, country].compact.join(', ')
    end

For reverse geocoding you can also specify an alternate name attribute where the address will be stored, for example:

    reverse_geocoded_by :latitude, :longitude, :address => :location  # ActiveRecord
    reverse_geocoded_by :coordinates, :address => :loc                # MongoDB


Advanced Querying
-----------------

When querying for objects (if you're using ActiveRecord) you can also look within a square rather than a radius (circle) by using the `within_bounding_box` scope:

    distance = 20
    center_point = [40.71, 100.23]
    box = Geocoder::Calculations.bounding_box(center_point, distance)
    Venue.within_bounding_box(box)

This can also dramatically improve query performance, especially when used in conjunction with indexes on the latitude/longitude columns. Note, however, that returned results do not include `distance` and `bearing` attributes. Note that `#near` performs both bounding box and radius queries for speed.


Advanced Geocoding
------------------

So far we have looked at shortcuts for assigning geocoding results to object attributes. However, if you need to do something fancy you can skip the auto-assignment by providing a block (takes the object to be geocoded and an array of `Geocoder::Result` objects) in which you handle the parsed geocoding result any way you like, for example:

    reverse_geocoded_by :latitude, :longitude do |obj,results|
      if geo = results.first
        obj.city    = geo.city
        obj.zipcode = geo.postal_code
        obj.country = geo.country_code
      end
    end
    after_validation :reverse_geocode

Every `Geocoder::Result` object, `result`, provides the following data:

* `result.latitude` - float
* `result.longitude` - float
* `result.coordinates` - array of the above two
* `result.address` - string
* `result.city` - string
* `result.state` - string
* `result.state_code` - string
* `result.postal_code` - string
* `result.country` - string
* `result.country_code` - string

If you're familiar with the results returned by the geocoding service you're using you can access even more data, but you'll need to be familiar with the particular `Geocoder::Result` object you're using and the structure of your geocoding service's responses. (See below for links to geocoding service documentation.)


Geocoding Services
------------------

By default Geocoder uses Google's geocoding API to fetch coordinates and street addresses (FreeGeoIP is the default for IP address info). However there are several other APIs supported, as well as a variety of settings. Please see the listing and comparison below for details on specific geocoding services (not all settings are supported by all services). Some common configuration options are:

    # config/initializers/geocoder.rb
    Geocoder.configure(

      # geocoding service (see below for supported options):
      :lookup => :yandex,

      # to use an API key:
      :api_key => "...",

      # geocoding service request timeout, in seconds (default 3):
      :timeout => 5,

      # set default units to kilometers:
      :units => :km,

      # caching (see below for details):
      :cache => Redis.new,
      :cache_prefix => "..."

    )

Please see lib/geocoder/configuration.rb for a complete list of configuration options. Additionally, some lookups have their own configuration options, some of which are directly supported by Geocoder. For example, to specify a value for Google's `bounds` parameter:

    # with Google:
    Geocoder.search("Paris", :bounds => [[32.1,-95.9], [33.9,-94.3]])

Please see the [source code for each lookup](https://github.com/alexreisner/geocoder/tree/master/lib/geocoder/lookups) to learn about directly supported parameters. Parameters which are not directly supported can be specified using the `:params` option, by which you can pass arbitrary parameters to any geocoding service. For example, to use Nominatim's `countrycodes` parameter:

    # with Nominatim:
    Geocoder.search("Paris", :params => {:countrycodes => "gb,de,fr,es,us"})


### Listing and Comparison

The following is a comparison of the supported geocoding APIs. The "Limitations" listed for each are a very brief and incomplete summary of some special limitations beyond basic data source attribution. Please read the official Terms of Service for a service before using it.

#### Google (`:google`, `:google_premier`)

* **API key**: required for Premier (do NOT use a key for the free version)
* **Key signup**: http://code.google.com/apis/maps/signup.html
* **Quota**: 2,500 requests/day, 100,000 with Google Maps API Premier
* **Region**: world
* **SSL support**: yes
* **Languages**: ar, eu, bg, bn, ca, cs, da, de, el, en, en-AU, en-GB, es, eu, fa, fi, fil, fr, gl, gu, hi, hr, hu, id, it, iw, ja, kn, ko, lt, lv, ml, mr, nl, no, pl, pt, pt-BR, pt-PT, ro, ru, sk, sl, sr, sv, tl, ta, te, th, tr, uk, vi, zh-CN, zh-TW (see http://spreadsheets.google.com/pub?key=p9pdwsai2hDMsLkXsoM05KQ&gid=1)
* **Extra options**: `:bounds` - pass SW and NE coordinates as an array of two arrays to bias results towards a viewport
* **Documentation**: http://code.google.com/apis/maps/documentation/geocoding/#JSON
* **Terms of Service**: http://code.google.com/apis/maps/terms.html#section_10_12
* **Limitations**: "You must not use or display the Content without a corresponding Google map, unless you are explicitly permitted to do so in the Maps APIs Documentation, or through written permission from Google." "You must not pre-fetch, cache, or store any Content, except that you may store: (i) limited amounts of Content for the purpose of improving the performance of your Maps API Implementation..."
* **Notes**: To use Google Premier set `Geocoder.configure(:lookup => :google_premier, :api_key => [key, client, channel])`.

#### Data Science Toolkit (`:dstk`)

* **Host**: if you are running this behind your own firewall
* **Quota**: no quota if you are running on your own hardware
* **Region**: world
* **SSL support**: ?
* **Languages**: en
* **Documentation**: http://www.datasciencetoolkit.org/developerdocs
* **Terms of Service**: http://www.datasciencetoolkit.org/developerdocs#googlestylegeocoder
* **Limitations**: None.

#### Yahoo BOSS (`:yahoo`)

Yahoo BOSS is **not a free service**. As of November 17, 2012 Yahoo no longer offers a free geocoding API.

* **API key**: requires OAuth consumer key and secret (set `Geocoder.configure(:api_key => [key, secret])`)
* **Key signup**: http://developer.yahoo.com/boss/geo/
* **Quota**: unlimited, but subject to usage fees
* **Region**: world
* **SSL support**: no
* **Languages**: en, fr, de, it, es, pt, nl, zh, ja, ko
* **Documentation**: http://developer.yahoo.com/boss/geo/docs/index.html
* **Terms of Service**: http://info.yahoo.com/legal/us/yahoo/boss/tou/?pir=ucJPcJ1ibUn.h.d.lVmlcbcEkoHjwJ_PvxG9SLK9VIbIQAw1XFrnDqY-
* **Limitations**: No mass downloads, no commercial map production based on the data, no storage of data except for caching.

#### Bing (`:bing`)

* **API key**: required
* **Key signup**: http://www.bingmapsportal.com
* **Quota**: 50,000 requests/24 hrs
* **Region**: world
* **SSL support**: no
* **Languages**: ?
* **Documentation**: http://msdn.microsoft.com/en-us/library/ff701715.aspx
* **Terms of Service**: http://www.microsoft.com/maps/product/terms.html
* **Limitations**: No country codes or state names. Must be used on "public-facing, non-password protected web sites," "in conjunction with Bing Maps or an application that integrates Bing Maps."

#### Nominatim (`:nominatim`)

* **API key**: none
* **Quota**: 1 request/second
* **Region**: world
* **SSL support**: no
* **Languages**: ?
* **Documentation**: http://wiki.openstreetmap.org/wiki/Nominatim
* **Terms of Service**: http://wiki.openstreetmap.org/wiki/Nominatim_usage_policy
* **Limitations**: Please limit request rate to 1 per second and include your contact information in User-Agent headers. Data licensed under CC-BY-SA (you must provide attribution).

#### Yandex (`:yandex`)

* **API key**: none
* **Quota**: 25000 requests / day
* **Region**: world
* **SSL support**: no
* **Languages**: Russian, Belarusian, Ukrainian, English, Turkish (only for maps of Turkey)
* **Documentation**: http://api.yandex.com.tr/maps/doc/intro/concepts/intro.xml
* **Terms of Service**: http://api.yandex.com.tr/maps/doc/intro/concepts/intro.xml#rules
* **Limitations**: ?

#### Geocoder.ca (`:geocoder_ca`)

* **API key**: none
* **Quota**: ?
* **Region**: US and Canada
* **SSL support**: no
* **Languages**: English
* **Documentation**: ?
* **Terms of Service**: http://geocoder.ca/?terms=1
* **Limitations**: "Under no circumstances can our data be re-distributed or re-sold by anyone to other parties without our written permission."

#### Mapquest (`:mapquest`)

* **API key**: required for the licensed API, do not use for open tier
* **Quota**: ?
* **HTTP Headers**: in order to use the licensed API you can configure the http_headers to include a referer as so:
    `Geocoder.configure(:http_headers => { "Referer" => "http://foo.com" })`
  You can also allow a blank referer from the API management console via mapquest but it is potentially a security risk that someone else could use your API key from another domain.
* **Region**: world
* **SSL support**: no
* **Languages**: English
* **Documentation**: http://www.mapquestapi.com/geocoding/
* **Terms of Service**: http://info.mapquest.com/terms-of-use/
* **Limitations**: ?

#### Ovi/Nokia (`:ovi`)

* **API key**: not required, but performance restricted without it
* **Quota**: ?
* **Region**: world
* **SSL support**: no
* **Languages**: English
* **Documentation**: http://api.maps.ovi.com/devguide/overview.html
* **Terms of Service**: http://www.developer.nokia.com/Develop/Maps/TC.html
* **Limitations**: ?

#### FreeGeoIP (`:freegeoip`)

* **API key**: none
* **Quota**: 10000 requests per hour.  After reaching the hourly quota, all of your requests will result in HTTP 403 (Forbidden) until it clears up on the next roll over.
* **Region**: world
* **SSL support**: no
* **Languages**: English
* **Documentation**: http://github.com/fiorix/freegeoip/blob/master/README.md
* **Terms of Service**: ?
* **Limitations**: ?

#### MaxMind Web Services (`:maxmind`)

* **API key**: required
* **Quota**: Request Packs can be purchased
* **Region**: world
* **SSL support**: yes
* **Languages**: English
* **Documentation**: http://www.maxmind.com/app/web_services
* **Terms of Service**: ?
* **Limitations**: ?
* **Notes**: You must specify which MaxMind service you are using in your configuration. For example: `Geocoder.configure(:maxmind => {:service => :omni})`.

#### ESRI (`:esri`)

* **API key**: none
* **Quota**: Required for some scenarios (see Terms of Service)
* **Region**: world
* **SSL support**: yes
* **Languages**: English
* **Documentation**: http://resources.arcgis.com/en/help/arcgis-online-geocoding-rest-api/
* **Terms of Service**: http://www.esri.com/software/arcgis/arcgisonline/services/geoservices
* **Limitations**: ?
* **Notes**: You can specify which projection you want to use by setting, for example: `Geocoder.configure(:esri => {:outSR => 102100})`.


Caching
-------

It's a good idea, when relying on any external service, to cache retrieved data. When implemented correctly it improves your app's response time and stability. It's easy to cache geocoding results with Geocoder, just configure a cache store:

    Geocoder.configure(:cache => Redis.new)

This example uses Redis, but the cache store can be any object that supports these methods:

* `store#[](key)`         - retrieves a value
* `store#[]=(key, value)` - stores a value
* `store#keys`            - lists all keys
* `store#del(url)`        - deletes a value

Even a plain Ruby hash will work, though it's not a great choice (cleared out when app is restarted, not shared between app instances, etc).

You can also set a custom prefix to be used for cache keys:

    Geocoder.configure(:cache_prefix => "...")

By default the prefix is `geocoder:`

If you need to expire cached content:

    Geocoder.cache.expire("http://...") # expire cached result for a URL
    Geocoder.cache.expire(:all)         # expire all cached results

Do *not* include the prefix when passing a URL to be expired. Expiring `:all` will only expire keys with the configured prefix (won't kill every entry in your key/value store).

For an example of a cache store with URL expiry please see examples/autoexpire_cache.rb

_Before you implement caching in your app please be sure that doing so does not violate the Terms of Service for your geocoding service._


Forward and Reverse Geocoding in the Same Model
-----------------------------------------------

If you apply both forward and reverse geocoding functionality to the same model (say users can supply an address or coordinates and you want to fill in whatever's missing), you will provide two address methods:

* one for storing the fetched address (reverse geocoding)
* one for providing an address to use when fetching coordinates (forward geocoding)

For example:

    class Venue

      # build an address from street, city, and state attributes
      geocoded_by :address_from_components

      # store the fetched address in the full_address attribute
      reverse_geocoded_by :latitude, :longitude, :address => :full_address
    end

However, there can be only one set of latitude/longitude attributes, and whichever you specify last will be used. For example:

    class Venue

      geocoded_by :address,
        :latitude  => :fetched_latitude,  # this will be overridden by the below
        :longitude => :fetched_longitude  # same here

      reverse_geocoded_by :latitude, :longitude
    end

The reason for this is that we don't want ambiguity when doing distance calculations. We need a single, authoritative source for coordinates!

Once both forward and reverse geocoding has been applied, it is possible to call them sequentially.

For example:

    class Venue

      after_validation :geocode, :reverse_geocode

    end

For certain geolocation services such as Google geolocation API this may cause issues during subsequent updates to database records if the longtitude and latitude coordinates cannot be associated known location address (on a large body of water for example). On subsequent callbacks the following call:

     after_validation :geocode

will alter the longtitude and latitude attributes based on the location field, which would be the closest known location to the original coordinates. In this case it is better to add conditions to each call, as not to override coordinates that do not have known location addresses associated with them.

For example:

    class Venue

      after_validation :reverse_geocode, :if => :has_coordinates
      after_validation :geocode, :if => :has_location, :unless => :has_coordinates

    end  

Use Outside of Rails
--------------------

You can use Geocoder outside of Rails by calling the `Geocoder.search` method:

    results = Geocoder.search("McCarren Park, Brooklyn, NY")

This returns an array of `Geocoder::Result` objects with all data provided by the geocoding service.


Testing Apps that Use Geocoder
------------------------------

When writing tests for an app that uses Geocoder it may be useful to avoid network calls and have Geocoder return consistent, configurable results. To do this, configure and use the `:test` lookup. For example:

    Geocoder.configure(:lookup => :test)

    Geocoder::Lookup::Test.add_stub(
      "New York, NY", [
        {
          'latitude'     => 40.7143528,
          'longitude'    => -74.0059731,
          'address'      => 'New York, NY, USA',
          'state'        => 'New York',
          'state_code'   => 'NY',
          'country'      => 'United States',
          'country_code' => 'US'
        }
      ]
    )

Now, any time Geocoder looks up "New York, NY" its results array will contain one result with the above attributes. You can also set a default stub:

    Geocoder.configure(:lookup => :test)

    Geocoder::Lookup::Test.set_default_stub(
      [
        {
          'latitude'     => 40.7143528,
          'longitude'    => -74.0059731,
          'address'      => 'New York, NY, USA',
          'state'        => 'New York',
          'state_code'   => 'NY',
          'country'      => 'United States',
          'country_code' => 'US'
        }
      ]
    )

Any query that hasn't been explicitly stubbed will return that result.

Command Line Interface
----------------------

When you install the Geocoder gem it adds a `geocode` command to your shell. You can search for a street address, IP address, postal code, coordinates, etc just like you can with the Geocoder.search method for example:

    $ geocode 29.951,-90.081
    Latitude:         29.952211
    Longitude:        -90.080563
    Full address:     1500 Sugar Bowl Dr, New Orleans, LA 70112, USA
    City:             New Orleans
    State/province:   Louisiana
    Postal code:      70112
    Country:          United States
    Google map:       http://maps.google.com/maps?q=29.952211,-90.080563

There are also a number of options for setting the geocoding API, key, and language, viewing the raw JSON reponse, and more. Please run `geocode -h` for details.

Notes on MongoDB
----------------

### The Near Method

Mongo document classes (Mongoid and MongoMapper) have a built-in `near` scope, but since it only works two-dimensions Geocoder overrides it with its own spherical `near` method in geocoded classes.

### Latitude/Longitude Order

Coordinates are generally printed and spoken as latitude, then longitude ([lat,lon]). Geocoder respects this convention and always expects method arguments to be given in [lat,lon] order. However, MongoDB requires that coordinates be stored in [lon,lat] order as per the GeoJSON spec (http://geojson.org/geojson-spec.html#positions), so internally they are stored "backwards." However, this does not affect order of arguments to methods when using Mongoid or MongoMapper.

To access an object's coordinates in the conventional order, use the `to_coordinates` instance method provided by Geocoder. For example:

    obj.to_coordinates  # => [37.7941013, -122.3951096] # [lat, lon]

Calling `obj.coordinates` directly returns the internal representation of the coordinates which, in the case of MongoDB, is probably the reverse of what you want:

    obj.coordinates     # => [-122.3951096, 37.7941013] # [lon, lat]

For consistency with the rest of Geocoder, always use the `to_coordinates` method instead.

Notes on Non-Rails Frameworks
-----------------------------

If you are using Geocoder with ActiveRecord and a framework other than Rails (like Sinatra or Padrino) you will need to add this in your model before calling Geocoder methods:

    extend Geocoder::Model::ActiveRecord 

Optimisation of Distance Queries
--------------------------------

In MySQL and Postgres the finding of objects near a given point is speeded up by using a bounding box to limit the number of points over which a full distance calculation needs to be done.

To take advantage of this optimisation you need to add a composite index on latitude and longitude. In your Rails migration:

    add_index :table, [:latitude, :longitude]


Distance Queries in SQLite
--------------------------

SQLite's lack of trigonometric functions requires an alternate implementation of the `near` scope. When using SQLite, Geocoder will automatically use a less accurate algorithm for finding objects near a given point. Results of this algorithm should not be trusted too much as it will return objects that are outside the given radius, along with inaccurate distance and bearing calculations.


### Discussion

There are few options for finding objects near a given point in SQLite without installing extensions:

1. Use a square instead of a circle for finding nearby points. For example, if you want to find points near 40.71, 100.23, search for objects with latitude between 39.71 and 41.71 and longitude between 99.23 and 101.23. One degree of latitude or longitude is at most 69 miles so divide your radius (in miles) by 69.0 to get the amount to add and subtract from your center coordinates to get the upper and lower bounds. The results will not be very accurate (you'll get points outside the desired radius), but you will get all the points within the required radius.

2. Load all objects into memory and compute distances between them using the `Geocoder::Calculations.distance_between` method. This will produce accurate results but will be very slow (and use a lot of memory) if you have a lot of objects in your database.

3. If you have a large number of objects (so you can't use approach #2) and you need accurate results (better than approach #1 will give), you can use a combination of the two. Get all the objects within a square around your center point, and then eliminate the ones that are too far away using `Geocoder::Calculations.distance_between`.

Because Geocoder needs to provide this functionality as a scope, we must go with option #1, but feel free to implement #2 or #3 if you need more accuracy.


Tests
-----

Geocoder comes with a test suite (just run `rake test`) that mocks ActiveRecord and is focused on testing the aspects of Geocoder that do not involve executing database queries. Geocoder uses many database engine-specific queries which must be tested against all supported databases (SQLite, MySQL, etc). Ideally this involves creating a full, working Rails application, and that seems beyond the scope of the included test suite. As such, I have created a separate repository which includes a full-blown Rails application and some utilities for easily running tests against multiple environments:

http://github.com/alexreisner/geocoder_test


Error Handling
--------------

By default Geocoder will rescue any exceptions raised by calls to a geocoding service and return an empty array (using warn() to inform you of the error). You can override this on a per-exception basis, and also have Geocoder raise its own exceptions for certain events (eg: API quota exceeded) by using the `:always_raise` option:

    Geocoder.configure(:always_raise => [SocketError, TimeoutError])

You can also do this to raise all exceptions:

    Geocoder.configure(:always_raise => :all)

The raise-able exceptions are:

    SocketError
    TimeoutError
    Geocoder::OverQueryLimitError
    Geocoder::RequestDenied
    Geocoder::InvalidRequest
    Geocoder::InvalidApiKey

Note that not all lookups support all exceptions.


Troubleshooting
---------------

### Mongoid

If you get one of these errors:

    uninitialized constant Geocoder::Model::Mongoid
    uninitialized constant Geocoder::Model::Mongoid::Mongo

you should check your Gemfile to make sure the Mongoid gem is listed _before_ Geocoder. If Mongoid isn't loaded when Geocoder is initialized, Geocoder will not load support for Mongoid.

### ActiveRecord

A lot of debugging time can be saved by understanding how Geocoder works with ActiveRecord. When you use the `near` scope or the `nearbys` method of a geocoded object, Geocoder creates an ActiveModel::Relation object which adds some attributes (eg: distance, bearing) to the SELECT clause. It also adds a condition to the WHERE clause to check that distance is within the given radius. Because the SELECT clause is modified, anything else that modifies the SELECT clause may produce strange results, for example:

* using the `pluck` method (selects only a single column)
* specifying another model through `includes` (selects columns from other tables)

### Unexpected Responses from Geocoding Services

Take a look at the server's raw JSON response. You can do this by getting the request URL in an app console:

    Geocoder::Lookup.get(:google).query_url(Geocoder::Query.new("..."))

Replace `:google` with the lookup you are using and replace `...` with the address you are trying to geocode. Then visit the returned URL in your web browser. Often the API will return an error message that helps you resolve the problem. If, after reading the raw response, you believe there is a problem with Geocoder, please post an issue and include both the URL and raw response body.


Reporting Issues
----------------

When reporting an issue, please list the version of Geocoder you are using and any relevant information about your application (Rails version, database type and version, etc). Also avoid vague language like "it doesn't work." Please describe as specifically as you can what behavior your are actually seeing (eg: an error message? a nil return value?).


Known Issue
-----------

You cannot use the `near` scope with another scope that provides an `includes` option because the `SELECT` clause generated by `near` will overwrite it (or vice versa). Instead, try using `joins` and pass a `:select` option to the `near` scope to get the columns you want. For example:

    # instead of City.near(...).includes(:venues)
    City.near("Omaha, NE", 20, :select => "cities.*, venues.*").joins(:venues)

If anyone has a more elegant solution to this problem I am very interested in seeing it.


Copyright (c) 2009-12 Alex Reisner, released under the MIT license
