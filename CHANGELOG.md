Changelog
=========

Major changes to Geocoder for each release. Please see the Git log for complete list of changes.

1.1.9 (2013 Dec 11)
-------------------

* DEPRECATED support for Ruby 1.8.x. Will be dropped in a future version.
* Require API key for MapQuest (thanks github.com/robdiciuccio).
* Add support for geocoder.us and HTTP basic auth (thanks github.com/komba).
* Add support for Data Science Toolkit lookup (thanks github.com/ejhayes).
* Add support for Baidu (thanks github.com/mclee).
* Add Geocoder::Calculations.random_point_near method (thanks github.com/adambray).
* Fix: #nearbys method with Mongoid (thanks github.com/pascalbetz).
* Fix: bug in FreeGeoIp lookup that was preventing exception from being raised when configured cache was unavailable.

1.1.8 (2013 Apr 22)
-------------------

* Fix bug in ESRI lookup that caused an exception on load in environments without rack/utils.

1.1.7 (2013 Apr 21)
-------------------

* Add support for Ovi/Nokia API (thanks github.com/datenimperator).
* Add support for ESRI API (thanks github.com/rpepato).
* Add ability to omit distance and bearing from SQL select clause (thanks github.com/nicolasdespres).
* Add support for caches that use read/write methods (thanks github.com/eskil).
* Add support for nautical miles (thanks github.com/vanboom).
* Fix: bug in parsing of MaxMind responses.
* Fix: bugs in query regular expressions (thanks github.com/boone).
* Fix: various bugs in MaxMind implementation.
* Fix: don't require a key for MapQuest.
* Fix: bug in handling of HTTP_X_FORWARDED_FOR header (thanks github.com/robdimarco).

1.1.6 (2012 Dec 24)
-------------------

* Major changes to configuration syntax which allow for API-specific config options. Old config syntax is now DEPRECATED.
* Add support for MaxMind API (thanks github.com/gonzoyumo).
* Add optional Geocoder::InvalidApiKey exception for bad API credentials (Yahoo, Yandex, Bing, and Maxmind). Warn when bad key and exception not set in Geocoder.configure(:always_raise => [...]).
* Add support for X-Real-IP and X-Forwarded-For headers (thanks github.com/konsti).
* Add support for custom Nominatim host config: Geocoder.configure(:nominatim => {:host => "..."}).
* Raise exception when required API key is missing or incorrect format.
* Add support for Google's :region and :components parameters (thanks to github.com/tomlion).
* Fix: string escaping bug in OAuth lib (thanks github.com/m0thman).
* Fix: configured units were not always respected in SQL queries.
* Fix: in #nearbys, don't try to exclude self if not yet persisted.
* Fix: bug with cache stores that provided #delete but not #del.
* Change #nearbys so that it returns nil instead of [] when object is not geocoded.

1.1.5 (2012 Nov 9)
------------------

* Replace support for old Yahoo Placefinder with Yahoo BOSS (thanks github.com/pwoltman).
* Add support for actual Mapquest API (was previously just a proxy for Nominatim), including the paid service (thanks github.com/jedschneider).
* Add support for :select => :id_only option to near scope.
* Treat a given query as blank (don't do a lookup) if coordinates are given but latitude or longitude is nil.
* Speed up 'near' queries by adding bounding box condition (thanks github.com/mlandauer).
* Fix: don't redefine Object#hash in Yahoo result object (thanks github.com/m0thman).

1.1.4 (2012 Oct 2)
------------------

* Deprecate Geocoder::Result::Nominatim#class and #type methods. Use #place_class and #place_type instead.
* Add support for setting arbitrary parameters in geocoding request URL.
* Add support for Google's :bounds parameter (thanks to github.com/rosscooperman and github.com/peterjm for submitting suggestions).
* Add support for :select => :geo_only option to near scope (thanks github.com/gugl).
* Add ability to omit ORDER BY clause from .near scope (pass option :order => false).
* Fix: error on Yahoo lookup due to API change (thanks github.com/kynesun).
* Fix: problem with Mongoid field aliases not being respected.
* Fix: :exclude option to .near scope when primary key != :id (thanks github.com/smisml).
* Much code refactoring (added Geocoder::Query class and Geocoder::Sql module).

1.1.3 (2012 Aug 26)
-------------------

* Add support for Mapquest geocoding service (thanks github.com/razorinc).
* Add :test lookup for easy testing of apps using Geocoder (thanks github.com/mguterl).
* Add #precision method to Yandex results (thanks github.com/gemaker).
* Add support for raising :all exceptions (thanks github.com/andyvb).
* Add exceptions for certain Google geocoder responses (thanks github.com/andyvb).
* Add Travis-CI integration (thanks github.com/petergoldstein).
* Fix: unit config was not working with SQLite (thanks github.com/balvig).
* Fix: get tests to pass under Jruby (thanks github.com/petergoldstein).
* Fix: bug in distance_from_sql method (error occurred when coordinates not found).
* Fix: incompatibility with Mongoid 3.0.x (thanks github.com/petergoldstein).

1.1.2 (2012 May 24)
-------------------

* Add ability to specify default units and distance calculation method (thanks github.com/abravalheri).
* Add new (optional) configuration syntax (thanks github.com/abravalheri).
* Add support for cache stores that provide :get and :set methods.
* Add support for custom HTTP request headers (thanks github.com/robotmay).
* Add Result#cache_hit attribute (thanks github.com/s01ipsist).
* Fix: rake geocode:all wasn't properly loading namespaced classes.
* Fix: properly recognize IP addresses with ::ffff: prefix (thanks github.com/brian-ewell).
* Fix: avoid exception during calculations when coordinates not known (thanks github.com/flori).

1.1.1 (2012 Feb 16)
-------------------

* Add distance_from_sql class method to geocoded class (thanks github.com/dwilkie).
* Add OverQueryLimitError and raise when relevant for Google lookup.
* Fix: don't cache API data if response indicates an error.
* Fix: within_bounding_box now uses correct lat/lon DB columns (thanks github.com/kongo).
* Fix: error accessing city in some cases with Yandex result (thanks github.com/kor6n and sld).

1.1.0 (2011 Dec 3)
------------------

* A block passed to geocoded_by is now always executed, even if the geocoding service returns no results. This means you need to make sure you have results before trying to assign data to your object.
* Fix issues with joins and row counts (issues #49, 86, and 108) by not using GROUP BY clause with ActiveRecord scopes.
* Fix incorrect object ID when join used (fixes issue #140).
* Fix calculation of bounding box which spans 180th meridian (thanks github.com/hwuethrich).
* Add within_bounding_box scope for ActiveRecord-based models (thanks github.com/gavinhughes and dbloete).
* Add option to raise Geocoder::OverQueryLimitError for Google geocoding service.
* Add support for Nominatim geocoding service (thanks github.com/wranglerdriver).
* Add support for API key to Geocoder.ca geocoding service (thanks github.com/ryanLonac).
* Add support for state to Yandex results (thanks github.com/tipugin).

1.0.5 (2011 Oct 26)
-------------------

* Fix error with `rake assets:precompile` (thanks github.com/Sush).
* Fix HTTPS support (thanks github.com/rsanheim).
* Improve cache interface.

1.0.4 (2011 Sep 18)
-------------------

* Remove klass method from rake task, which could conflict with app methods (thanks github.com/mguterl).

1.0.3 (2011 Sep 17)
-------------------

* Add support for Google Premier geocoding service (thanks github.com/steveh).
* Update Google API URL (thanks github.com/soorajb).
* Allow rescue from timeout with FreeGeoIP (thanks github.com/lukeledet).
* Fix: rake assets:precompile (Rails 3.1) not working in some situations.
* Fix: stop double-adjusting units when using kilometers (thanks github.com/hairyheron).

1.0.2 (2011 June 25)
--------------------

* Add support for MongoMapper (thanks github.com/spagalloco).
* Fix: user-specified coordinates field wasn't working with Mongoid (thanks github.com/thisduck).
* Fix: invalid location given to near scope was returning all results (Active Record) or error (Mongoid) (thanks github.com/ogennadi).

1.0.1 (2011 May 17)
-------------------

* Add option to not rescue from certain exceptions (thanks github.com/ahmedrb).
* Fix STI child/parent geocoding bug (thanks github.com/ogennadi).
* Other bugfixes.

1.0.0 (2011 May 9)
------------------

* Add command line interface.
* Add support for local proxy (thanks github.com/Olivier).
* Add support for Yandex.ru geocoding service.
* Add support for Bing geocoding service (thanks github.com/astevens).
* Fix single table inheritance bug (reported by github.com/enrico).
* Fix bug when Google result supplies no city (thanks github.com/jkeen).

0.9.13 (2011 Apr 11)
--------------------

* Fix "can't find special index: 2d" error when using Mongoid with Ruby 1.8.

0.9.12 (2011 Apr 6)
-------------------

* Add support for Mongoid.
* Add bearing_to/from methods to geocoded objects.
* Improve SQLite's distance calculation heuristic.
* Fix: Geocoder::Calculations.geographic_center was modifying its argument in-place (reported by github.com/joelmats).
* Fix: sort 'near' query results by distance when using SQLite.
* Clean up input: search for coordinates as a string with space after comma yields zero results from Google. Now we get rid of any such space before sending the query.
* DEPRECATION: Geocoder.near should not take <tt>:limit</tt> or <tt>:offset</tt> options.
* DEPRECATION: Change argument format of all methods that take lat/lon as separate arguments. Now you must pass the coordinates as an array [lat,lon], but you may alternatively pass a address string (will look up coordinates) or a geocoded object (or any object that implements a to_coordinates method which returns a [lat,lon] array).

0.9.11 (2011 Mar 25)
--------------------

* Add support for result caching.
* Add support for Geocoder.ca geocoding service.
* Add +bearing+ attribute to objects returned by geo-aware queries (thanks github.com/matellis).
* Add config setting: language.
* Add config settings: +use_https+, +google_api_key+ (thanks github.com/svesely).
* DEPRECATION: <tt>Geocoder.search</tt> now returns an array instead of a single result.
* DEPRECATION: <tt>obj.nearbys</tt> second argument is now an options hash (instead of units). Please change <tt>obj.nearbys(20, :km)</tt> to: <tt>obj.nearbys(20, :units => :km)</tt>.

0.9.10 (2011 Mar 9)
-------------------

* Fix broken scopes (github.com/mikepinde).
* Fix broken Ruby 1.9 and JRuby compatibility (don't require json gem).

0.9.9 (2011 Mar 9)
------------------

* Add support for IP address geocoding via FreeGeoIp.net.
* Add support for Yahoo PlaceFinder geocoding API.
* Add support for custom geocoder data handling by passing a block to geocoded_by or reverse_geocoded_by.
* Add <tt>Rack::Request#location</tt> method for geocoding user's IP address.
* Change gem name to geocoder (no more rails-geocoder).
* Gem now works outside of Rails.
* DEPRECATION: +fetch_coordinates+ no longer takes an argument.
* DEPRECATION: +fetch_address+ no longer takes an argument.
* DEPRECATION: <tt>Geocoder.search</tt> now returns a single result instead of an array.
* DEPRECATION: <tt>fetch_coordinates!</tt> has been superceded by +geocode+ (then save your object manually).
* DEPRECATION: <tt>fetch_address!</tt> has been superceded by +reverse_geocode+ (then save your object manually).
* Fix: don't die when trying to get coordinates with a nil address (github.com/zmack).

0.9.8 (2011 Feb 8)
------------------

* Include <tt>geocode:all</tt> Rake task in gem (was missing!).
* Add <tt>Geocoder.search</tt> for access to Google's full response.
* Add ability to configure Google connection timeout.
* Emit warnings on Google connection problems and errors.
* Refactor: insert Geocoder into ActiveRecord via Railtie.

0.9.7 (2011 Feb 1)
------------------

* Add reverse geocoding (+reverse_geocoded_by+).
* Prevent exception (uninitialized constant Geocoder::Net) when net/http not already required (github.com/sleepycat).
* Refactor: split monolithic Geocoder module into several smaller ones.

0.9.6 (2011 Jan 19)
-------------------

* Fix incompatibility with will_paginate gem.
* Include table names in GROUP BY clause of nearby scope to avoid ambiguity in joins (github.com/matchu).

0.9.5 (2010 Oct 15)
-------------------

* Fix broken PostgreSQL compatibility (now 100% compatible).
* Switch from Google's XML to JSON geocoding API.
* Separate Rails 2 and Rails 3-compatible branches.
* Don't allow :conditions hash in 'options' argument to 'nearbys' method (was deprecated in 0.9.3).

0.9.4 (2010 Aug 2)
------------------

* Google Maps API key no longer required (uses geocoder v3).

0.9.3 (2010 Aug 2)
------------------

* Fix incompatibility with Rails 3 RC 1.
* Deprecate 'options' argument to 'nearbys' method.
* Allow inclusion of 'nearbys' in Arel method chains.

0.9.2 (2010 Jun 3)
------------------

* Fix LIMIT clause bug in PostgreSQL (reported by github.com/kenzie).

0.9.1 (2010 May 4)
------------------

* Use scope instead of named_scope in Rails 3.

0.9.0 (2010 Apr 2)
------------------

* Fix bug in PostgreSQL support (caused "PGError: ERROR:  column "distance" does not exist"), reported by github.com/developish.

0.8.9 (2010 Feb 11)
-------------------

* Add Rails 3 compatibility.
* Avoid querying Google when query would be an empty string.

0.8.8 (2009 Dec 7)
------------------

* Automatically select a less accurate but compatible distance algorithm when SQLite database detected (fixes SQLite incompatibility).

0.8.7 (2009 Nov 4)
------------------

* Added Geocoder.geographic_center method.
* Replaced _get_coordinates class method with read_coordinates instance method.

0.8.6 (2009 Oct 27)
-------------------

* The fetch_coordinates method now assigns coordinates to attributes (behaves like fetch_coordinates! used to) and fetch_coordinates! both assigns and saves the attributes.
* Added geocode:all rake task.

0.8.5 (2009 Oct 26)
-------------------

* Avoid calling deprecated method from within Geocoder itself.

0.8.4 (2009 Oct 23)
-------------------

* Deprecate <tt>find_near</tt> class method in favor of +near+ named scope.

0.8.3 (2009 Oct 23)
-------------------

* Update Google URL query string parameter to reflect recent changes in Google's API.

0.8.2 (2009 Oct 12)
-------------------

* Allow a model's geocoder search string method to be something other than an ActiveRecord attribute.
* Clean up documentation.

0.8.1 (2009 Oct 8)
------------------

* Extract XML-fetching code from <tt>Geocoder.search</tt> and place in Geocoder._fetch_xml (for ease of mocking).
* Add tests for coordinate-fetching instance methods.

0.8.0 (2009 Oct 1)
------------------

First release.
