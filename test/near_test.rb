require 'test_helper'

class NearTest < Test::Unit::TestCase

  def test_near_scope_options
    result = Event.near_scope_options(1.0, 2.0, 5)
    expected = {
      :order => "distance",
      :limit => nil,
      :offset => nil,
      :select =>
        "table.*, 3958.755864232 * 2 * ASIN(SQRT(POWER(SIN((1.0 - table.latitude) * PI() / 180 / 2), 2) + COS(1.0 * PI() / 180) * COS(table.latitude * PI() / 180) * POWER(SIN((2.0 - table.longitude) * PI() / 180 / 2), 2) )) AS distance, CAST(DEGREES(ATAN2( RADIANS(table.longitude - 2.0), RADIANS(table.latitude - 1.0))) + 360 AS decimal) % 360 AS bearing",
      :conditions =>
        ["3958.755864232 * 2 * ASIN(SQRT(POWER(SIN((1.0 - table.latitude) * PI() / 180 / 2), 2) + COS(1.0 * PI() / 180) * COS(table.latitude * PI() / 180) * POWER(SIN((2.0 - table.longitude) * PI() / 180 / 2), 2) )) <= ?", 5]
    }

    assert_equal expected, result
  end
end
