# encoding: utf-8
require 'test_helper'

class UkOrdnanceSurveyNamesTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(lookup: :uk_ordnance_survey_names)
    set_api_key!(:uk_ordnance_survey_names)
  end

  def test_result_on_placename_search
    result = Geocoder.search('London').first
    assert_in_delta 51.51437, result.coordinates[0]
    assert_in_delta -0.09227, result.coordinates[1]
  end

  def test_result_on_postcode_search
    result = Geocoder.search('SW1A1AA').first
    assert_in_delta 51.50100, result.coordinates[0]
    assert_in_delta -0.14157, result.coordinates[1]
  end
end
