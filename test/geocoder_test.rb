# encoding: utf-8
require 'test_helper'

class GeocoderTest < Test::Unit::TestCase

  def setup
    Geocoder::Configuration.set_defaults
  end


  # --- configuration ---
  #
  def test_exception_raised_on_bad_lookup_config
    Geocoder::Configuration.lookup = :stoopid
    assert_raises Geocoder::ConfigurationError do
      Geocoder.search "something dumb"
    end
  end


  # --- sanity checks ---

  def test_uses_proxy_when_specified
    Geocoder::Configuration.http_proxy = 'localhost'
    lookup = Geocoder::Lookup::Google.new
    assert lookup.send(:http_client).proxy_class?
  end

  def test_doesnt_use_proxy_when_not_specified
    lookup = Geocoder::Lookup::Google.new
    assert !lookup.send(:http_client).proxy_class?
  end

  def test_exception_raised_on_bad_proxy_url
    Geocoder::Configuration.http_proxy = ' \\_O< Quack Quack'
    assert_raise Geocoder::ConfigurationError do
      Geocoder::Lookup::Google.new.send(:http_client)
    end
  end

  def test_uses_https_for_secure_query
    Geocoder::Configuration.use_https = true
    g = Geocoder::Lookup::Google.new
    assert_match /^https:/, g.send(:query_url, {:a => 1, :b => 2})
  end

  def test_uses_http_by_default
    g = Geocoder::Lookup::Google.new
    assert_match /^http:/, g.send(:query_url, {:a => 1, :b => 2})
  end

  def test_distance_to_returns_float
    v = Venue.new(*venue_params(:msg))
    v.latitude, v.longitude = [40.750354, -73.993371]
    assert (d = v.distance_to([30, -94])).is_a?(Float)
  end

  def test_distance_from_is_alias_for_distance_to
    v = Venue.new(*venue_params(:msg))
    v.latitude, v.longitude = [40.750354, -73.993371]
    assert_equal v.distance_from([30, -94]), v.distance_to([30, -94])
  end

  def test_coordinates_method
    assert Geocoder.coordinates("Madison Square Garden, New York, NY").is_a?(Array)
  end

  def test_address_method
    assert Geocoder.address([40.750354, -73.993371]).is_a?(String)
  end

  def test_geographic_center_doesnt_overwrite_argument_value
    # this tests for the presence of a bug that was introduced in version 0.9.11
    orig_points = [[52,8], [46,9], [42,5]]
    points = orig_points.clone
    Geocoder::Calculations.geographic_center(points)
    assert_equal orig_points, points
  end


  # --- general ---

  def test_geocode_assigns_and_returns_coordinates
    v = Venue.new(*venue_params(:msg))
    coords = [40.750354, -73.993371]
    assert_equal coords, v.geocode
    assert_equal coords, [v.latitude, v.longitude]
  end

  def test_reverse_geocode_assigns_and_returns_address
    v = Landmark.new(*landmark_params(:msg))
    address = "4 Penn Plaza, New York, NY 10001, USA"
    assert_equal address, v.reverse_geocode
    assert_equal address, v.address
  end

  def test_geocode_with_block_runs_block
    e = Event.new(*venue_params(:msg))
    coords = [40.750354, -73.993371]
    e.geocode
    assert_equal coords.map{ |c| c.to_s }.join(','), e.coords_string
  end

  def test_geocode_with_block_doesnt_auto_assign_coordinates
    e = Event.new(*venue_params(:msg))
    e.geocode
    assert_nil e.latitude
    assert_nil e.longitude
  end

  def test_reverse_geocode_with_block_runs_block
    e = Party.new(*landmark_params(:msg))
    e.reverse_geocode
    assert_equal "US", e.country
  end

  def test_reverse_geocode_with_block_doesnt_auto_assign_address
    e = Party.new(*landmark_params(:msg))
    e.reverse_geocode
    assert_nil e.address
  end

  def test_forward_and_reverse_geocoding_on_same_model
    g = GasStation.new("Exxon")
    g.address = "404 New St, Middletown, CT"
    g.geocode
    assert_not_nil g.lat
    assert_not_nil g.lon

    assert_nil g.location
    g.reverse_geocode
    assert_not_nil g.location
  end

  def test_fetch_coordinates_is_alias_for_geocode
    v = Venue.new(*venue_params(:msg))
    coords = [40.750354, -73.993371]
    assert_equal coords, v.fetch_coordinates
    assert_equal coords, [v.latitude, v.longitude]
  end

  def test_fetch_address_is_alias_for_reverse_geocode
    v = Landmark.new(*landmark_params(:msg))
    address = "4 Penn Plaza, New York, NY 10001, USA"
    assert_equal address, v.fetch_address
    assert_equal address, v.address
  end

  def test_search_returns_empty_array_when_no_results
    street_lookups.each do |l|
      Geocoder::Configuration.lookup = l
      assert_equal [], Geocoder.search("no results"),
        "Lookup #{l} does not return empty array when no results."
    end
  end

  def test_result_has_required_attributes
    all_lookups.each do |l|
      Geocoder::Configuration.lookup = l
      result = Geocoder.search([45.423733, -75.676333]).first
      assert_result_has_required_attributes(result)
    end
  end


  # --- calculations: degree distance ---

  def test_longitude_degree_distance_at_equator
    assert_equal 69, Geocoder::Calculations.longitude_degree_distance(0).round
  end

  def test_longitude_degree_distance_at_new_york
    assert_equal 53, Geocoder::Calculations.longitude_degree_distance(40).round
  end

  def test_longitude_degree_distance_at_north_pole
    assert_equal 0, Geocoder::Calculations.longitude_degree_distance(89.98).round
  end


  # --- calculations: distance between ---

  def test_distance_between_in_miles
    assert_equal 69, Geocoder::Calculations.distance_between([0,0], [0,1]).round
    la_to_ny = Geocoder::Calculations.distance_between([34.05,-118.25], [40.72,-74]).round
    assert (la_to_ny - 2444).abs < 10
  end

  def test_distance_between_in_kilometers
    assert_equal 111, Geocoder::Calculations.distance_between([0,0], [0,1], :units => :km).round
    la_to_ny = Geocoder::Calculations.distance_between([34.05,-118.25], [40.72,-74], :units => :km).round
    assert (la_to_ny - 3942).abs < 10
  end


  # --- calculations: geographic center ---

  def test_geographic_center_with_arrays
    assert_equal [0.0, 0.5],
      Geocoder::Calculations.geographic_center([[0,0], [0,1]])
    assert_equal [0.0, 1.0],
      Geocoder::Calculations.geographic_center([[0,0], [0,1], [0,2]])
  end

  def test_geographic_center_with_mixed_arguments
    p1 = [0, 0]
    p2 = Landmark.new("Some Cold Place", 0, 1)
    assert_equal [0.0, 0.5], Geocoder::Calculations.geographic_center([p1, p2])
  end


  # --- calculations: bounding box ---

  def test_bounding_box_calculation_in_miles
    center = [51, 7] # Cologne, DE
    radius = 10 # miles
    dlon = radius / Geocoder::Calculations.latitude_degree_distance
    dlat = radius / Geocoder::Calculations.longitude_degree_distance(center[0])
    corners = [50.86, 6.77, 51.14, 7.23]
    assert_equal corners.map{ |i| (i * 100).round },
      Geocoder::Calculations.bounding_box(center, radius).map{ |i| (i * 100).round }
  end

  def test_bounding_box_calculation_in_kilometers
    center = [51, 7] # Cologne, DE
    radius = 111 # kilometers (= 1 degree latitude)
    dlon = radius / Geocoder::Calculations.latitude_degree_distance(:km)
    dlat = radius / Geocoder::Calculations.longitude_degree_distance(center[0], :km)
    corners = [50, 5.41, 52, 8.59]
    assert_equal corners.map{ |i| (i * 100).round },
      Geocoder::Calculations.bounding_box(center, radius, :units => :km).map{ |i| (i * 100).round }
  end

  def test_bounding_box_calculation_with_object
    center = [51, 7] # Cologne, DE
    radius = 10 # miles
    dlon = radius / Geocoder::Calculations.latitude_degree_distance
    dlat = radius / Geocoder::Calculations.longitude_degree_distance(center[0])
    corners = [50.86, 6.77, 51.14, 7.23]
    obj = Landmark.new("Cologne", center[0], center[1])
    assert_equal corners.map{ |i| (i * 100).round },
      Geocoder::Calculations.bounding_box(obj, radius).map{ |i| (i * 100).round }
  end

  def test_bounding_box_calculation_with_address_string
    assert_nothing_raised do
      Geocoder::Calculations.bounding_box("4893 Clay St, San Francisco, CA", 50)
    end
  end


  # --- calculations: bearing ---

  def test_compass_points
    assert_equal "N",  Geocoder::Calculations.compass_point(0)
    assert_equal "N",  Geocoder::Calculations.compass_point(1.0)
    assert_equal "N",  Geocoder::Calculations.compass_point(360)
    assert_equal "N",  Geocoder::Calculations.compass_point(361)
    assert_equal "N",  Geocoder::Calculations.compass_point(-22)
    assert_equal "NW", Geocoder::Calculations.compass_point(-23)
    assert_equal "S",  Geocoder::Calculations.compass_point(180)
    assert_equal "S",  Geocoder::Calculations.compass_point(181)
  end

  def test_bearing_between
    bearings = {
      :n => 0,
      :e => 90,
      :s => 180,
      :w => 270
    }
    points = {
      :n => [41, -75],
      :e => [40, -74],
      :s => [39, -75],
      :w => [40, -76]
    }
    directions = [:n, :e, :s, :w]
    methods = [:linear, :spherical]

    methods.each do |m|
      directions.each_with_index do |d,i|
        opp = directions[(i + 2) % 4] # opposite direction
        b = Geocoder::Calculations.bearing_between(
          points[d], points[opp], :method => m)
        assert (b - bearings[opp]).abs < 1,
          "Bearing (#{m}) should be close to #{bearings[opp]} but was #{b}."
      end
    end
  end

  def test_spherical_bearing_to
    l = Landmark.new(*landmark_params(:msg))
    assert_equal 324, l.bearing_to([50,-85], :method => :spherical).round
  end

  def test_spherical_bearing_from
    l = Landmark.new(*landmark_params(:msg))
    assert_equal 136, l.bearing_from([50,-85], :method => :spherical).round
  end

  def test_linear_bearing_from_and_to_are_exactly_opposite
    l = Landmark.new(*landmark_params(:msg))
    assert_equal l.bearing_from([50,-86.1]), l.bearing_to([50,-86.1]) - 180
  end


  # --- input handling ---

  def test_ip_address_detection
    assert Geocoder.send(:ip_address?, "232.65.123.94")
    assert Geocoder.send(:ip_address?, "666.65.123.94") # technically invalid
    assert !Geocoder.send(:ip_address?, "232.65.123.94.43")
    assert !Geocoder.send(:ip_address?, "232.65.123")
  end

  def test_blank_query_detection
    assert Geocoder.send(:blank_query?, nil)
    assert Geocoder.send(:blank_query?, "")
    assert Geocoder.send(:blank_query?, "\t  ")
    assert !Geocoder.send(:blank_query?, "a")
    assert !Geocoder.send(:blank_query?, "Москва") # no ASCII characters
  end

  def test_coordinates_detection
    lookup = Geocoder::Lookup::Google.new
    assert lookup.send(:coordinates?, "51.178844,5")
    assert lookup.send(:coordinates?, "51.178844, -1.826189")
    assert !lookup.send(:coordinates?, "232.65.123")
  end

  def test_does_not_choke_on_nil_address
    all_lookups.each do |l|
      Geocoder::Configuration.lookup = l
      assert_nothing_raised { Venue.new("Venue", nil).geocode }
    end
  end

  def test_extract_coordinates
    coords = [-23,47]
    l = Landmark.new("Madagascar", coords[0], coords[1])
    assert_equal coords, Geocoder::Calculations.extract_coordinates(l)
    assert_equal coords, Geocoder::Calculations.extract_coordinates(coords)
  end


  # --- error handling ---

  def test_does_not_choke_on_timeout
    # keep test output clean: suppress timeout warning
    orig = $VERBOSE; $VERBOSE = nil
    all_lookups.each do |l|
      Geocoder::Configuration.lookup = l
      assert_nothing_raised { Geocoder.search("timeout") }
    end
    $VERBOSE = orig
  end


  def test_always_raise_timeout_error
    Geocoder::Configuration.always_raise = [TimeoutError]
    assert_raise(TimeoutError) { Geocoder.search("timeout") }
    Geocoder::Configuration.always_raise = []
  end


  def test_always_raise_socket_error
    Geocoder::Configuration.always_raise = [SocketError]
    assert_raise(SocketError) { Geocoder.search("socket_error") }
    Geocoder::Configuration.always_raise = []
  end

  # --- Google ---

  def test_google_result_components
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Manhattan",
      result.address_components_of_type(:sublocality).first['long_name']
  end

  def test_google_returns_city_when_no_locality_in_result
    result = Geocoder.search("no locality").first
    assert_equal "Haram", result.city
  end

  def test_google_city_results_returns_nil_if_no_matching_component_types
    result = Geocoder.search("no city data").first
    assert_equal nil, result.city
  end

  # --- Yahoo ---

  def test_yahoo_result_components
    Geocoder::Configuration.lookup = :yahoo
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "10001", result.postal_code
  end

  def test_yahoo_address_formatting
    Geocoder::Configuration.lookup = :yahoo
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Madison Square Garden, New York, NY  10001, United States",
      result.address
  end


  # --- Yandex ---

  def test_yandex_with_invalid_key
    # keep test output clean: suppress timeout warning
    orig = $VERBOSE; $VERBOSE = nil
    Geocoder::Configuration.lookup = :yandex
    assert_equal [], Geocoder.search("invalid key")
    $VERBOSE = orig
  end


  # --- Geocoder.ca ---

  def test_geocoder_ca_result_components
    Geocoder::Configuration.lookup = :geocoder_ca
    result = Geocoder.search([45.423733, -75.676333]).first
    assert_equal "CA", result.country_code
    assert_equal "289 Somerset ST E, Ottawa, ON K1N6W1, Canada", result.address
  end


  # --- FreeGeoIp ---

  def test_freegeoip_result_on_ip_address_search
    result = Geocoder.search("74.200.247.59").first
    assert result.is_a?(Geocoder::Result::Freegeoip)
  end

  def test_freegeoip_result_components
    result = Geocoder.search("74.200.247.59").first
    assert_equal "Plano, TX 75093, United States", result.address
  end


  # --- Bing ---

  def test_bing_result_components
    Geocoder::Configuration.lookup = :bing
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Madison Square Garden, NY", result.address
    assert_equal "NY", result.state
    assert_equal "New York", result.city
  end

  def test_bing_no_results
    Geocoder::Configuration.lookup = :bing
    results = Geocoder.search("no results")
    assert_equal 0, results.length
  end


  # --- search queries ---

  def test_hash_to_query
    g = Geocoder::Lookup::Google.new
    assert_equal "a=1&b=2", g.send(:hash_to_query, {:a => 1, :b => 2})
  end

  def test_google_api_key
    Geocoder::Configuration.api_key = "MY_KEY"
    g = Geocoder::Lookup::Google.new
    assert_match "key=MY_KEY", g.send(:query_url, "Madison Square Garden, New York, NY  10001, United States")
  end

  def test_yahoo_app_id
    Geocoder::Configuration.api_key = "MY_KEY"
    g = Geocoder::Lookup::Yahoo.new
    assert_match "appid=MY_KEY", g.send(:query_url, "Madison Square Garden, New York, NY  10001, United States")
  end


  private # ------------------------------------------------------------------

  def assert_result_has_required_attributes(result)
    m = "Lookup #{Geocoder::Configuration.lookup} does not support %s attribute."
    assert result.coordinates.is_a?(Array),    m % "coordinates"
    assert result.latitude.is_a?(Float),       m % "latitude"
    assert result.longitude.is_a?(Float),      m % "longitude"
    assert result.city.is_a?(String),          m % "city"
    assert result.state.is_a?(String),         m % "state"
    assert result.state_code.is_a?(String),    m % "state_code"
    assert result.province.is_a?(String),      m % "province"
    assert result.province_code.is_a?(String), m % "province_code"
    assert result.postal_code.is_a?(String),   m % "postal_code"
    assert result.country.is_a?(String),       m % "country"
    assert result.country_code.is_a?(String),  m % "country_code"
    assert_not_nil result.address,             m % "address"
  end
end
