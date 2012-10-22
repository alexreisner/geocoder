require 'test_helper'

class NearTest < Test::Unit::TestCase

  def test_near_scope_options
    result = Event.near_scope_options(1.0, 2.0, 5)
    expected = {
      :select =>
        "test_table_name.*, 3958.755864232 * 2 * ASIN(SQRT(POWER(SIN((1.0 - test_table_name.latitude) * PI() / 180 / 2), 2) + COS(1.0 * PI() / 180) * COS(test_table_name.latitude * PI() / 180) * POWER(SIN((2.0 - test_table_name.longitude) * PI() / 180 / 2), 2))) AS distance, CAST(DEGREES(ATAN2( RADIANS(test_table_name.longitude - 2.0), RADIANS(test_table_name.latitude - 1.0))) + 360 AS decimal) % 360 AS bearing",
      :conditions =>
        ["3958.755864232 * 2 * ASIN(SQRT(POWER(SIN((1.0 - test_table_name.latitude) * PI() / 180 / 2), 2) + COS(1.0 * PI() / 180) * COS(test_table_name.latitude * PI() / 180) * POWER(SIN((2.0 - test_table_name.longitude) * PI() / 180 / 2), 2))) <= ?", 5],
      :order => "distance ASC"
    }

    assert_equal expected, result
  end
end
