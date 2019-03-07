# encoding: utf-8
require 'test_helper'

class NationaalGeoregisterNlTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :nationaal_georegister_nl)
  end

  def test_result_components
    result = Geocoder.search('Nieuwezijds Voorburgwal 147, 1012 RJ Amsterdam').first

    assert_equal result.city,         'Amsterdam'
    assert_equal result.postcode,     '1012RJ'
    assert_equal result.address,      'Nieuwezijds Voorburgwal 147, 1012RJ Amsterdam'
    assert_equal result.country_code, 'NL'
  end

end
