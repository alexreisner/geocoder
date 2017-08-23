# encoding: utf-8
require 'test_helper'

class ExcludeConditionTest < GeocoderTestCase

  def test_exclude_condition_when_model_has_a_custom_primary_key
    venue = PlaceWithCustomPrimaryKey.new(*geocoded_object_params(:msg))
    klass = venue.class

    # just call private method directly so we don't have to stub .near scope
    if defined?(Sequel)
      klass = venue.class.dataset # this method is on the dataset class
    end

    conditions = klass.send(:add_exclude_condition, ["fake_condition"], venue)

    assert_match( /#{PlaceWithCustomPrimaryKey.primary_key}/, conditions.join)
  end

end
