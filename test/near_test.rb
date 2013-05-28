require 'test_helper'

class NearTest < Test::Unit::TestCase

  def test_near_scope_options_without_sqlite_includes_bounding_box_condition
    result = Event.send(:near_scope_options, 1.0, 2.0, 5)

    assert_match /test_table_name.latitude BETWEEN 0.9276\d* AND 1.0723\d* AND test_table_name.longitude BETWEEN 1.9276\d* AND 2.0723\d* AND /,
      result[:conditions][0]
  end

  def test_near_scope_options_with_defaults
    result = Event.send(:near_scope_options, 1.0, 2.0, 5)

    assert_match /AS distance/, result[:select]
    assert_match /AS bearing/, result[:select]
    assert_no_consecutive_comma(result[:select])
  end

  def test_near_scope_options_with_no_distance
    result = Event.send(:near_scope_options, 1.0, 2.0, 5, :select_distance => false)

    assert_no_match /AS distance/, result[:select]
    assert_match /AS bearing/, result[:select]
    assert_no_match /distance/, result[:condition]
    assert_no_match /distance/, result[:order]
    assert_no_consecutive_comma(result[:select])
  end

  def test_near_scope_options_with_no_bearing
    result = Event.send(:near_scope_options, 1.0, 2.0, 5, :select_bearing => false)

    assert_match /AS distance/, result[:select]
    assert_no_match /AS bearing/, result[:select]
    assert_no_consecutive_comma(result[:select])
  end

  def test_near_scope_with_order_function_without_select
    options = {:order_function => "(distance * 2) AS RANK_ORDER"}
    sql = Event.send(:distance_sql, 1.0, 2.0, options)
    result = Event.send(:near_scope_options, 1.0, 2.0, 5, options)

    assert_include result[:select], "(#{sql} * 2) AS RANK_ORDER"
  end

  def test_near_scope_with_order_function_with_select
    options = {:order_function => "(distance * 2) AS RANK_ORDER", :select => "name AS events_name"}
    sql = Event.send(:distance_sql, 1.0, 2.0, options)
    result = Event.send(:near_scope_options, 1.0, 2.0, 5, options)

    assert_include result[:select], "(#{sql} * 2) AS RANK_ORDER"
    assert_include result[:select], "name AS events_name"
  end

  private

  def assert_no_consecutive_comma(string)
    assert_no_match /, *,/, string, "two consecutive commas"
  end
end
