# encoding: utf-8
require 'test_helper'

class CacheTest < Test::Unit::TestCase

  def test_second_occurrence_of_request_is_cache_hit
    Geocoder.configure(:cache => {})
    Geocoder::Lookup.all_services_except_test.each do |l|
      Geocoder.configure(:lookup => l)
      set_api_key!(l)
      results = Geocoder.search("Madison Square Garden")
      assert !results.first.cache_hit,
        "Lookup #{l} returned erroneously cached result."
      results = Geocoder.search("Madison Square Garden")
      assert results.first.cache_hit,
        "Lookup #{l} did not return cached result."
    end
  end
end
