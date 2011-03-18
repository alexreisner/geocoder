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

  def test_distance_between
    assert_equal 69, Geocoder::Calculations.distance_between(0,0, 0,1).round
  end

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

  def test_does_not_choke_on_nil_address
    all_lookups.each do |l|
      Geocoder::Configuration.lookup = l
      assert_nothing_raised { Venue.new("Venue", nil).geocode }
    end
  end

  def test_does_not_choke_on_timeout
    # keep test output clean: suppress timeout warning
    orig = $VERBOSE; $VERBOSE = nil
    all_lookups.each do |l|
      Geocoder::Configuration.lookup = l
      assert_nothing_raised { Geocoder.search("timeout") }
    end
    $VERBOSE = orig
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
    assert (d = v.distance_to(30, -94)).is_a?(Float)
  end

  def test_distance_from_is_alias_for_distance_to
    v = Venue.new(*venue_params(:msg))
    v.latitude, v.longitude = [40.750354, -73.993371]
    assert_equal v.distance_from(30, -94), v.distance_to(30, -94)
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

  def test_returns_nil_when_no_results
    street_lookups.each do |l|
      Geocoder::Configuration.lookup = l
      assert_nil Geocoder.search("no results"),
        "Lookup #{l} does not return nil when no results."
    end
  end

  def test_result_has_required_attributes
    all_lookups.each do |l|
      Geocoder::Configuration.lookup = l
      result = Geocoder.search(45.423733, -75.676333)
      assert_result_has_required_attributes(result)
    end
  end


  # --- Google ---

  def test_google_result_components
    result = Geocoder.search("Madison Square Garden, New York, NY")
    assert_equal "Manhattan",
      result.address_components_of_type(:sublocality).first['long_name']
  end

  def test_google_returns_city_when_no_locality_in_result
    result = Geocoder.search("no locality")
    assert_equal "Haram", result.city
  end


  # --- Yahoo ---

  def test_yahoo_result_components
    Geocoder::Configuration.lookup = :yahoo
    result = Geocoder.search("Madison Square Garden, New York, NY")
    assert_equal "10001", result.postal_code
  end

  def test_yahoo_address_formatting
    Geocoder::Configuration.lookup = :yahoo
    result = Geocoder.search("Madison Square Garden, New York, NY")
    assert_equal "Madison Square Garden, New York, NY  10001, United States",
      result.address
  end


  # --- Geocoder.ca ---

  def test_geocoder_ca_result_components
    Geocoder::Configuration.lookup = :geocoder_ca
    result = Geocoder.search(45.423733, -75.676333)
    assert_equal "CA", result.country_code
    assert_equal "289 Somerset ST E, Ottawa, ON K1N6W1, Canada", result.address
  end


  # --- FreeGeoIp ---

  def test_freegeoip_result_on_ip_address_search
    result = Geocoder.search("74.200.247.59")
    assert result.is_a?(Geocoder::Result::Freegeoip)
  end

  def test_freegeoip_result_components
    result = Geocoder.search("74.200.247.59")
    assert_equal "Plano, TX 75093, United States", result.address
  end


  # --- search queries ---

  def test_ip_address_detection
    assert Geocoder.send(:ip_address?, "232.65.123.94")
    assert Geocoder.send(:ip_address?, "666.65.123.94") # technically invalid
    assert !Geocoder.send(:ip_address?, "232.65.123.94.43")
    assert !Geocoder.send(:ip_address?, "232.65.123")
  end

  def test_blank_query_detection
    assert Geocoder.send(:blank_query?, nil)
    assert Geocoder.send(:blank_query?, "")
    assert Geocoder.send(:blank_query?, ", , (-)")
    assert !Geocoder.send(:blank_query?, "a")
  end

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
    assert result.coordinates.is_a?(Array),   m % "coordinates"
    assert result.latitude.is_a?(Float),      m % "latitude"
    assert result.longitude.is_a?(Float),     m % "longitude"
    assert result.city.is_a?(String),         m % "city"
    assert result.postal_code.is_a?(String),  m % "postal_code"
    assert result.country.is_a?(String),      m % "country"
    assert result.country_code.is_a?(String), m % "country_code"
    assert_not_nil result.address,            m % "address"
  end
end
