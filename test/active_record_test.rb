# encoding: utf-8
require 'test_helper'

class ActiveRecordTest < Test::Unit::TestCase

  def test_exclude_condition_when_model_has_a_custom_primary_key
    venue = VenuePlus.new(*venue_params(:msg))

    # just call private method directly so we don't have to stub .near scope
    conditions = venue.class.send(:add_exclude_condition, ["fake_condition"], venue)

    assert_match( /#{VenuePlus.primary_key}/, conditions.join)
  end

end
