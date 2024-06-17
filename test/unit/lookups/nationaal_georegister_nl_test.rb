# encoding: utf-8
require 'test_helper'

class NationaalGeoregisterNlTest < GeocoderTestCase

  def setup
    super
    Geocoder.configure(lookup: :nationaal_georegister_nl)
  end

  def test_result_components
    result = Geocoder.search('Nieuwezijds Voorburgwal 147, Amsterdam').first

    assert_equal result.street,         'Nieuwezijds Voorburgwal'
    assert_equal result.street_number,  '147'
    assert_equal result.city,           'Amsterdam'
    assert_equal result.postal_code,    '1012RJ'
    assert_equal result.address,        'Nieuwezijds Voorburgwal 147, 1012RJ Amsterdam'
    assert_equal result.province,       'Noord-Holland'
    assert_equal result.province_code,  'PV27'
    assert_equal result.country_code,   'NL'
    assert_equal result.latitude,       52.37316397
    assert_equal result.longitude,      4.89089949
  end
end
