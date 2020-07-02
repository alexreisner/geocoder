# frozen_string_literal: true

require 'test_helper'

class UtilTest < GeocoderTestCase
  def test_recursive_hash_merge
    h1 = { 'a' => 100, 'b' => 200, 'c' => { 'c1' => 12, 'c2' => 14 } }
    h2 = { 'b' => 254, 'c' => { 'c1' => 16, 'c3' => 94 } }
    Geocoder::Util.recursive_hash_merge(h1, h2)
    assert h1 == { 'a' => 100, 'b' => 254, 'c' => { 'c1' => 16, 'c2' => 14, 'c3' => 94 } }
  end
end
