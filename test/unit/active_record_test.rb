# encoding: utf-8
$: << File.join(File.dirname(__FILE__), "..")
require 'test_helper'

class ActiveRecordTest < GeocoderTestCase

  def test_exclude_condition_when_model_has_a_custom_primary_key
    venue = PlaceWithCustomPrimaryKey.new(*geocoded_object_params(:msg))

    # just call private method directly so we don't have to stub .near scope
    conditions = venue.class.send(:add_exclude_condition, ["fake_condition"], venue)

    assert_match( /#{PlaceWithCustomPrimaryKey.primary_key}/, conditions.join)
  end

end
