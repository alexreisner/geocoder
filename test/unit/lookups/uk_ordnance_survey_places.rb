# encoding: utf-8
require 'test_helper'

class UkOrdnanceSurveyPlacesTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(lookup: :uk_ordnance_survey_places)
    set_api_key!(:uk_ordnance_survey_places)
  end

  def test_result_on_postcode_search
    result = Geocoder.search('SW152QH').first
    assert_in_delta 51.4559931, result.coordinates[0]
    assert_in_delta -0.2257836, result.coordinates[1]
  end
end
