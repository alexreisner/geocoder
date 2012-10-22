require 'test_helper'

class NearTest < Test::Unit::TestCase

  def test_near_scope_options_without_sqlite_includes_bounding_box_condition
    result = Event.send(:near_scope_options, 1.0, 2.0, 5)

    assert_match /test_table_name.latitude BETWEEN 0.9276\d* AND 1.0723\d* AND test_table_name.longitude BETWEEN 1.9276\d* AND 2.0723\d* AND /,
      result[:conditions][0]
  end
end
