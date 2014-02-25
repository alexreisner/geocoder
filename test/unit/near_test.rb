# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..")
require 'test_helper'

class NearTest < GeocoderTestCase

  def test_near_scope_options_without_sqlite_includes_bounding_box_condition
    result = PlaceWithCustomResultsHandling.send(:near_scope_options, 1.0, 2.0, 5)
    assert_match(/test_table_name.latitude BETWEEN 0.9276\d* AND 1.0723\d* AND test_table_name.longitude BETWEEN 1.9276\d* AND 2.0723\d* AND /, result[:conditions][0])
  end

  def test_near_scope_options_without_sqlite_includes_radius_condition
    result = Place.send(:near_scope_options, 1.0, 2.0, 5)
    assert_match(/BETWEEN \? AND \?$/, result[:conditions][0])
  end

  def test_near_scope_options_without_sqlite_includes_radius_default_min_radius
    result = Place.send(:near_scope_options, 1.0, 2.0, 5)

    assert_equal(0, result[:conditions][1])
    assert_equal(5, result[:conditions][2])
  end

  def test_near_scope_options_without_sqlite_includes_radius_custom_min_radius
    result = Place.send(:near_scope_options, 1.0, 2.0, 5, :min_radius => 3)

    assert_equal(3, result[:conditions][1])
    assert_equal(5, result[:conditions][2])
  end

  def test_near_scope_options_without_sqlite_includes_radius_bogus_min_radius
    result = Place.send(:near_scope_options, 1.0, 2.0, 5, :min_radius => 'bogus')

    assert_equal(0, result[:conditions][1])
    assert_equal(5, result[:conditions][2])
  end

  def test_near_scope_options_with_defaults
    result = PlaceWithCustomResultsHandling.send(:near_scope_options, 1.0, 2.0, 5)

    assert_match(/AS distance/, result[:select])
    assert_match(/AS bearing/, result[:select])
    assert_no_consecutive_comma(result[:select])
  end

  def test_near_scope_options_with_no_distance
    result = PlaceWithCustomResultsHandling.send(:near_scope_options, 1.0, 2.0, 5, :select_distance => false)

    assert_no_match(/AS distance/, result[:select])
    assert_match(/AS bearing/, result[:select])
    assert_no_match(/distance/, result[:condition])
    assert_no_match(/distance/, result[:order])
    assert_no_consecutive_comma(result[:select])
  end

  def test_near_scope_options_with_no_bearing
    result = PlaceWithCustomResultsHandling.send(:near_scope_options, 1.0, 2.0, 5, :select_bearing => false)

    assert_match(/AS distance/, result[:select])
    assert_no_match(/AS bearing/, result[:select])
    assert_no_consecutive_comma(result[:select])
  end

  def test_near_scope_options_with_custom_distance_column
    result = PlaceWithCustomResultsHandling.send(:near_scope_options, 1.0, 2.0, 5, :distance_column => 'calculated_distance')

    assert_no_match(/AS distance/, result[:select])
    assert_match(/AS calculated_distance/, result[:select])
    assert_no_match(/\bdistance\b/, result[:order])
    assert_match(/calculated_distance/, result[:order])
    assert_no_consecutive_comma(result[:select])
  end

  def test_near_scope_options_with_custom_bearing_column
    result = PlaceWithCustomResultsHandling.send(:near_scope_options, 1.0, 2.0, 5, :bearing_column => 'calculated_bearing')

    assert_no_match(/AS bearing/, result[:select])
    assert_match(/AS calculated_bearing/, result[:select])
    assert_no_consecutive_comma(result[:select])
  end

  private

  def assert_no_consecutive_comma(string)
    assert_no_match(/, *,/, string, "two consecutive commas")
  end
end
